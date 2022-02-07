//
//  CoreDataBudgetStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 05/02/2022.
//

import Foundation
import CoreData

final class CoreDataBudgetStorageProvider: BudgetStorageProvider {

    // MARK: Types

    private let persistentContainer: NSPersistentContainer

    // MARK: Object life cycle

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: Budget list

    func fetchBudgets() async throws -> [Budget] {
        let budgetEntities = try fetchBudgetEntities()
        let budgets = try budgetEntities.compactMap(Budget.with(budgetEntity:))
        return budgets
    }

    func add(budget: Budget) async throws -> [Budget] {
        let budgetEntity = BudgetEntity(context: persistentContainer.viewContext)
        budgetEntity.identifier = budget.id
        budgetEntity.name = budget.name
        budgetEntity.slices = NSSet(array: budget.slices.map { slice in
            let sliceEntity = BudgetSliceEntity(context: persistentContainer.viewContext)
            sliceEntity.identifier = slice.id
            sliceEntity.name = slice.name
            sliceEntity.amount = NSDecimalNumber(decimal: slice.amount.value)
            sliceEntity.budget = budgetEntity
            return sliceEntity
        })

        try saveOrRollback()
        return try await fetchBudgets()
    }

    func delete(budget: Budget) async throws -> [Budget] {
        let budgetEntity = try fetchBudgetEntity(with: budget.id)
        persistentContainer.viewContext.delete(budgetEntity)

        try saveOrRollback()
        return try await fetchBudgets()
    }

    func delete(budgets: [Budget]) async throws -> [Budget] {
        let budgetsEntities = try fetchBudgetEntities()
        let idsToRemove = Set(budgets.map(\.id))
        budgetsEntities.forEach { budgetEntity in
            if let identifier = budgetEntity.identifier, idsToRemove.contains(identifier) {
                self.persistentContainer.viewContext.delete(budgetEntity)
            }
        }

        try saveOrRollback()
        return try await fetchBudgets()
    }

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: identifier)

        do {
            return try Budget.with(budgetEntity: budgetEntity)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.budgetProvider(error: .underlying(error: error))
        }
    }

    func updateBudget(budget: Budget) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: budget.id)
        budgetEntity.name = budget.name

        let entitySlices = budgetEntity.slices?.compactMap { $0 as? BudgetSliceEntity } ?? []
        entitySlices.forEach { sliceEntity in
            if !budget.slices.contains(where: { $0.id == sliceEntity.identifier }) {
                self.persistentContainer.viewContext.delete(sliceEntity)
            }
        }
        budget.slices.forEach { slice in
            if !entitySlices.contains(where: { $0.identifier == slice.id }) {
                let sliceEntity = BudgetSliceEntity(context: self.persistentContainer.viewContext)
                sliceEntity.identifier = slice.id
                sliceEntity.name = slice.name
                sliceEntity.amount = NSDecimalNumber(decimal: slice.amount.value)
                sliceEntity.budget = budgetEntity
            }
        }

        try saveOrRollback()
        return try await fetchBudget(with: budget.id)
    }

    // MARK: Private fetching methods

    private func fetchBudgetEntities() throws -> [BudgetEntity] {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            return entities
        } catch {
            throw DomainError.budgetProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID) throws -> BudgetEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchBudgetsRequest.predicate = predicate

        do {
            guard let budgetEntity = try persistentContainer.viewContext.fetch(fetchBudgetsRequest).first else {
                throw DomainError.budgetProvider(error: .budgetEntityNotFound)
            }
            return budgetEntity
        } catch {
            throw DomainError.budgetProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetSliceEntity(with identifier: BudgetSlice.ID) throws -> BudgetSliceEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.identifier), identifier as CVarArg)
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            guard let budgetSliceEntity = try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest).first else {
                throw DomainError.budgetProvider(error: .budgetEntityNotFound)
            }
            return budgetSliceEntity
        } catch {
            throw DomainError.budgetProvider(error: .underlying(error: error))
        }
    }

    // MARK: Private saving methods

    private func saveOrRollback() throws {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            throw DomainError.budgetProvider(error: .underlying(error: error))
        }
    }
}

// MARK: Private Extensions

private extension Budget {

    static func with(budgetEntity: BudgetEntity) throws -> Budget {
        guard let identifier = budgetEntity.identifier,
              let name = budgetEntity.name,
              let slices = budgetEntity.slices else {
                  throw DomainError.budgetProvider(error: .cannotCreateBudgetWithEntity)
        }

        let budgetSlices = slices
            .compactMap { $0 as? BudgetSliceEntity }
            .compactMap { BudgetSlice.with(budgetSliceEntity: $0) }

        return try Budget(id: identifier, name: name, slices: budgetSlices)
    }
}

private extension BudgetSlice {

    static func with(budgetSliceEntity: BudgetSliceEntity) -> Self? {
        guard let identifier = budgetSliceEntity.identifier,
              let name = budgetSliceEntity.name,
              let amountDecimal = budgetSliceEntity.amount else {
            return nil
        }

        return try? BudgetSlice(id: identifier, name: name, amount: .value(amountDecimal.decimalValue))
    }
}
