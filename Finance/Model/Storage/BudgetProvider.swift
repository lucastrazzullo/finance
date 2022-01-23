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

    // MARK: Object life cycle

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
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

        saveOrRollback(completion: completion)
    }

    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.MutateCompletion) {
        fetchBudgetEntity(with: budgetId) { [weak self] result in
            guard let self = self else {
                completion(.failure(Error.budgetEntityNotFound))
                return
            }

            switch result {
            case .success(let budgetEntity):
                let sliceEntity = BudgetSliceEntity(context: self.persistentContainer.viewContext)
                sliceEntity.identifier = budgetSlice.id
                sliceEntity.name = budgetSlice.name
                sliceEntity.amount = NSDecimalNumber(decimal: budgetSlice.amount.value)
                sliceEntity.budget = budgetEntity

                self.saveOrRollback(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }


    }

    func delete(budget: Budget, completion: @escaping BudgetProvider.MutateCompletion) {
        fetchBudgetEntity(with: budget.id) { [weak self] result in
            guard let self = self else {
                completion(.failure(Error.budgetEntityNotFound))
                return
            }

            switch result {
            case .success(let budgetEntity):
                self.persistentContainer.viewContext.delete(budgetEntity)
                self.saveOrRollback(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchBudgets(completion: @escaping BudgetProvider.FetchCompletion) {
        fetchBudgetEntities { result in
            switch result {
            case .success(let budgetEntities):
                let budgets = budgetEntities.compactMap(Budget.with(budgetEntity:))
                completion(.success(budgets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Private helper methods

    private func fetchBudgetEntities(completion: @escaping (Result<[BudgetEntity], Swift.Error>) -> Void) {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            completion(.success(entities))
        } catch {
            completion(.failure(error))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID, completion: @escaping (Result<BudgetEntity, Swift.Error>) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchBudgetsRequest.predicate = predicate

        do {
            guard let budgetEntity = try persistentContainer.viewContext.fetch(fetchBudgetsRequest).first else {
                completion(.failure(Error.budgetEntityNotFound))
                return
            }
            completion(.success(budgetEntity))
        } catch {
            completion(.failure(error))
        }
    }

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
