//
//  BudgetStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation
import CoreData

protocol BudgetProvider {
    func save(budget: Budget, completion: ((Result<Void, Error>) -> Void)?)
    func delete(budget: Budget, completion: ((Result<Void, Error>) -> Void)?)
    func fetchBudgets(completion: (Result<[Budget], Error>) -> Void)
}

final class BudgetStorageProvider: BudgetProvider {

    enum StorageError: Error {
        case entityNotFound
    }

    private let persistentContainer: NSPersistentContainer

    private var budgetEntities: Set<BudgetEntity>

    // MARK: Object life cycle

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.budgetEntities = []
    }

    // MARK: Internal methods

    func save(budget: Budget, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let budgetEntity = BudgetEntity(context: persistentContainer.viewContext)
        updateBudgetEntity(budgetEntity, with: budget)
        budgetEntities.insert(budgetEntity)
        save(completion: completion)
    }

    func delete(budget: Budget, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let entity = budgetEntities.first(where: { $0.identifier == budget.id }) else {
            completion?(.failure(StorageError.entityNotFound))
            return
        }

        persistentContainer.viewContext.delete(entity)
        save { [weak self] result in
            if case .success = result {
                self?.budgetEntities.remove(entity)
            }

            completion?(result)
        }
    }

    func fetchBudgets(completion: (Result<[Budget], Error>) -> Void) {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            budgetEntities = Set(entities)

            let budgets = entities.compactMap(Budget.with(budgetEntity:))
            completion(.success(budgets))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: Private helper methods

    private func updateBudgetEntity(_ entity: BudgetEntity, with budget: Budget) {
        entity.identifier = budget.id
        entity.name = budget.name
        entity.slices = NSSet(array: budget.slices.map { slice in
            let sliceEntity = BudgetSliceEntity(context: persistentContainer.viewContext)
            sliceEntity.budget = entity
            sliceEntity.name = slice.name
            sliceEntity.amount = NSDecimalNumber(decimal: slice.amount.value)
            return sliceEntity
        })
    }

    private func save(completion: ((Result<Void, Error>) -> Void)?) {
        do {
            try persistentContainer.viewContext.save()
            completion?(.success(Void()))
        } catch {
            persistentContainer.viewContext.rollback()
            completion?(.failure(error))
        }
    }
}
