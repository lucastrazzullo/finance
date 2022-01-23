//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation
import CoreData

protocol BudgetProvider: AnyObject {
    typealias MutateCompletion = ((Result<Void, Swift.Error>) -> Void)
    typealias FetchCompletion = (Result<[Budget], Swift.Error>) -> Void
    func add(budget: Budget, completion: @escaping MutateCompletion)
    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping MutateCompletion)
    func delete(budget: Budget, completion: @escaping MutateCompletion)
    func fetchBudgets(completion: @escaping FetchCompletion)
}

final class BudgetStorageProvider: BudgetProvider {

    // MARK: Types

    enum Error: Swift.Error {
        case budgetEntityNotFound
    }

    private let persistentContainer: NSPersistentContainer

    private var budgetEntities: Set<BudgetEntity>

    // MARK: Object life cycle

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.budgetEntities = []
    }

    // MARK: Internal methods

    func add(budget: Budget, completion: BudgetProvider.MutateCompletion) {
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

        saveOrRollback { [weak self] result in
            if case .success = result {
                self?.budgetEntities.insert(budgetEntity)
            }

            completion(result)
        }
    }

    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.MutateCompletion) {
        guard let budgetEntity = budgetEntities.first(where: { $0.identifier == budgetId }) else {
            completion(.failure(Error.budgetEntityNotFound))
            return
        }

        let sliceEntity = BudgetSliceEntity(context: persistentContainer.viewContext)
        sliceEntity.identifier = budgetSlice.id
        sliceEntity.name = budgetSlice.name
        sliceEntity.amount = NSDecimalNumber(decimal: budgetSlice.amount.value)
        sliceEntity.budget = budgetEntity

        saveOrRollback(completion: completion)
    }

    func delete(budget: Budget, completion: @escaping BudgetProvider.MutateCompletion) {
        guard let entity = budgetEntities.first(where: { $0.identifier == budget.id }) else {
            completion(.failure(Error.budgetEntityNotFound))
            return
        }

        persistentContainer.viewContext.delete(entity)
        saveOrRollback { [weak self] result in
            if case .success = result {
                self?.budgetEntities.remove(entity)
            }

            completion(result)
        }
    }

    func fetchBudgets(completion: @escaping BudgetProvider.FetchCompletion) {
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

    private func saveOrRollback(completion: ((Result<Void, Swift.Error>) -> Void)) {
        do {
            try persistentContainer.viewContext.save()
            completion(.success(Void()))
        } catch {
            persistentContainer.viewContext.rollback()
            completion(.failure(error))
        }
    }
}
