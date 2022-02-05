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

    func fetchBudgets(completion: @escaping BudgetProvider.BudgetListCompletion) {
        fetchBudgetEntities { result in
            switch result {
            case .success(let budgetEntities):
                do {
                    let budgets = try budgetEntities.compactMap(Budget.with(budgetEntity:))
                    completion(.success(budgets))
                } catch let error as DomainError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.budgetProvider(error: .underlying(error: error))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func add(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion) {
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

        saveOrRollback { result in
            switch result {
            case .success:
                fetchBudgets(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion) {
        fetchBudgetEntity(with: budget.id) { [weak self] result in
            guard let self = self else {
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
                return
            }

            switch result {
            case .success(let budgetEntity):
                self.persistentContainer.viewContext.delete(budgetEntity)
                self.saveOrRollback { result in
                    switch result {
                    case .success:
                        self.fetchBudgets(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(budgets: [Budget], completion: @escaping BudgetProvider.BudgetListCompletion) {
        fetchBudgetEntities { [weak self] result in
            guard let self = self else {
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
                return
            }

            let idsToRemove = Set(budgets.map(\.id))

            switch result {
            case .success(let budgetsEntities):
                budgetsEntities.forEach { budgetEntity in
                    if let identifier = budgetEntity.identifier, idsToRemove.contains(identifier) {
                        self.persistentContainer.viewContext.delete(budgetEntity)
                    }
                }
                self.saveOrRollback { result in
                    switch result {
                    case .success:
                        self.fetchBudgets(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion) {
        fetchBudgetEntity(with: identifier) { result in
            switch result {
            case .success(let budgetEntity):
                do {
                    let budget = try Budget.with(budgetEntity: budgetEntity)
                    completion(.success(budget))
                } catch let error as DomainError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.budgetProvider(error: .underlying(error: error))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateBudget(budget: Budget, completion: @escaping BudgetProvider.BudgetCompletion) {
        fetchBudgetEntity(with: budget.id) { result in
            switch result {
            case .success(let budgetEntity):
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
                self.saveOrRollback { result in
                    switch result {
                    case .success:
                        self.fetchBudget(with: budget.id, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Private fetching methods

    private func fetchBudgetEntities(completion: @escaping (Result<[BudgetEntity], DomainError>) -> Void) {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            completion(.success(entities))
        } catch {
            completion(.failure(.budgetProvider(error: .underlying(error: error))))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID, completion: @escaping (Result<BudgetEntity, DomainError>) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchBudgetsRequest.predicate = predicate

        do {
            guard let budgetEntity = try persistentContainer.viewContext.fetch(fetchBudgetsRequest).first else {
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
                return
            }
            completion(.success(budgetEntity))
        } catch {
            completion(.failure(.budgetProvider(error: .underlying(error: error))))
        }
    }

    private func fetchBudgetSliceEntity(with identifier: BudgetSlice.ID, completion: @escaping (Result<BudgetSliceEntity, DomainError>) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.identifier), identifier as CVarArg)
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            guard let budgetSliceEntity = try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest).first else {
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
                return
            }
            completion(.success(budgetSliceEntity))
        } catch {
            completion(.failure(.budgetProvider(error: .underlying(error: error))))
        }
    }

    // MARK: Private saving methods

    private func saveOrRollback(completion: ((Result<Void, DomainError>) -> Void)) {
        do {
            try persistentContainer.viewContext.save()
            completion(.success(Void()))
        } catch {
            persistentContainer.viewContext.rollback()
            completion(.failure(.budgetProvider(error: .underlying(error: error))))
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
