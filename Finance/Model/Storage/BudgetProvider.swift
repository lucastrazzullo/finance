//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol BudgetStorageProvider: AnyObject {

    // MARK: Budget list

    func fetchBudgets(completion: @escaping BudgetProvider.BudgetListCompletion)
    func add(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion)
    func delete(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion)
    func delete(budgets: [Budget], completion: @escaping BudgetProvider.BudgetListCompletion)

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion)
    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion)
    func delete(budgetSlice: BudgetSlice, fromBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion)
}

final class BudgetProvider {

    typealias BudgetListCompletion = (Result<[Budget], DomainError>) -> Void
    typealias BudgetCompletion = (Result<Budget, DomainError>) -> Void

    // MARK: Instance properties

    private let storageProvider: BudgetStorageProvider

    init(storageProvider: BudgetStorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Budget list

    func fetchBudgets(completion: @escaping BudgetListCompletion) {
        storageProvider.fetchBudgets(completion: completion)
    }

    func add(budget: Budget, completion: @escaping BudgetListCompletion) {
        canAdd(budget: budget) { [weak self] result in
            switch result {
            case .success:
                self?.storageProvider.add(budget: budget, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(budget: Budget, completion: @escaping BudgetListCompletion) {
        storageProvider.delete(budget: budget, completion: completion)
    }

    func delete(budgets: [Budget], completion: @escaping BudgetListCompletion) {
        storageProvider.delete(budgets: budgets, completion: completion)
    }

    // MARK: Budget

    func fetchBudget(with id: Budget.ID, completion: @escaping BudgetCompletion) {
        storageProvider.fetchBudget(with: id, completion: completion)
    }

    // MARK: Private helper methods

    private func canAdd(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        storageProvider.fetchBudgets { result in
            switch result {
            case .success(let budgets):
                guard !budgets.contains(where: { $0.name == budget.name }) else {
                    completion(.failure(DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))))
                    return
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
