//
//  CoreDataStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/01/2022.
//

import CoreData

final class CoreDataStorageProvider: ObservableObject, StorageProvider {

    private static let storageContainerName = "Finance"

    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: Self.storageContainerName)
        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }

    // MARK: Report

    func fetchReport() async throws -> Report {
        let budgetEntities = try fetchBudgetEntities()
        let budgets = try budgetEntities.compactMap(Budget.with(budgetEntity:))
        let report = Report(budgets: budgets)
        return report
    }

    // MARK: Budget

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: identifier)

        do {
            return try Budget.with(budgetEntity: budgetEntity)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    func delete(budgetWith identifier: Budget.ID) async throws -> Report {
        if let budgetEntity = try? fetchBudgetEntity(with: identifier) {
            persistentContainer.viewContext.delete(budgetEntity)
        }

        try saveOrRollback()
        return try await fetchReport()
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Report {
        let budgetsEntities = try fetchBudgetEntities()
        budgetsEntities.forEach { budgetEntity in
            if let identifier = budgetEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(budgetEntity)
            }
        }

        try saveOrRollback()
        return try await fetchReport()
    }

    func add(budget: Budget) async throws -> Report {
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
        return try await fetchReport()
    }

    func update(budget: Budget) async throws -> Budget {
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
        return try await fetch(budgetWith: budget.id)
    }

    // MARK: Private fetching methods

    private func fetchBudgetEntities() throws -> [BudgetEntity] {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            return entities
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID) throws -> BudgetEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchBudgetsRequest.predicate = predicate

        do {
            guard let budgetEntity = try persistentContainer.viewContext.fetch(fetchBudgetsRequest).first else {
                throw DomainError.storageProvider(error: .budgetEntityNotFound)
            }
            return budgetEntity
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetSliceEntity(with identifier: BudgetSlice.ID) throws -> BudgetSliceEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.identifier), identifier as CVarArg)
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            guard let budgetSliceEntity = try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest).first else {
                throw DomainError.storageProvider(error: .budgetEntityNotFound)
            }
            return budgetSliceEntity
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    // MARK: Private saving methods

    private func saveOrRollback() throws {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }
}

// MARK: Private Extensions

private extension Budget {

    static func with(budgetEntity: BudgetEntity) throws -> Budget {
        guard let identifier = budgetEntity.identifier,
              let name = budgetEntity.name,
              let slices = budgetEntity.slices else {
                  throw DomainError.storageProvider(error: .cannotCreateBudgetWithEntity)
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
