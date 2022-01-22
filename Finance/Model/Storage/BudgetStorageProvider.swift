//
//  BudgetStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation
import CoreData

final class BudgetStorageProvider {

    enum StorageError: Error {
        case entityNotFound
    }

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    // MARK: Internal methods

    func save(budget: Budget, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let budgetEntity = BudgetEntity(context: persistentContainer.viewContext)
        updateBudgetEntity(budgetEntity, with: budget)
        save(completion: completion)
    }

    func delete(budgetEntity: BudgetEntity, completion: ((Result<Void, Error>) -> Void)? = nil) {
        persistentContainer.viewContext.delete(budgetEntity)
        save(completion: completion)
    }

    func fetchBudgetEntities(completion: (Result<[BudgetEntity], Error>) -> Void) {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            completion(.success(entities))
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
