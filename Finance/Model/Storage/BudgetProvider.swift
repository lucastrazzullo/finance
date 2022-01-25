//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation
import CoreData

protocol BudgetProvider: AnyObject {
    typealias MutateCompletion = ((Result<Void, DomainError>) -> Void)
    typealias FetchCompletion = (Result<[Budget], DomainError>) -> Void
    func add(budget: Budget, completion: @escaping MutateCompletion)
    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping MutateCompletion)
    func delete(budget: Budget, completion: @escaping MutateCompletion)
    func delete(budgetSlice: BudgetSlice, completion: @escaping MutateCompletion)
    func fetchBudgets(completion: @escaping FetchCompletion)
}

final class BudgetStorageProvider: BudgetProvider {

    // MARK: Types

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
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
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
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
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

    func delete(budgetSlice: BudgetSlice, completion: @escaping MutateCompletion) {
        fetchBudgetSliceEntity(with: budgetSlice.id) { [weak self] result in
            guard let self = self else {
                completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
                return
            }

            switch result {
            case .success(let budgetSliceEntity):
                self.persistentContainer.viewContext.delete(budgetSliceEntity)
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
