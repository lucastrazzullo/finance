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
    func updateBudget(budget: Budget, completion: @escaping BudgetProvider.BudgetCompletion)
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

    func update(budget: Budget, completion: @escaping BudgetCompletion) {
        canUpdate(budget: budget) { [weak self] result in
            switch result {
            case .success:
                self?.storageProvider.updateBudget(budget: budget, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

    private func canUpdate(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        storageProvider.fetchBudgets { result in
            switch result {
            case .success(let budgets):
                guard !budgets.contains(where: { $0.id != budget.id && $0.name == budget.name }) else {
                    completion(.failure(DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))))
                    return
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func canAdd(budgetSlice: BudgetSlice, toBudgetWith id: Budget.ID, completion: @escaping (Result<Void, DomainError>) -> Void) {
        storageProvider.fetchBudget(with: id) { result in
            switch result {
            case .success(let budget):
                do {
                    try Budget.canAdd(slice: budgetSlice, to: budget.slices)
                    completion(.success(()))
                } catch {
                    completion(.failure(error as? DomainError ?? .budgetProvider(error: .underlying(error: error))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func canDelete(budgetSlice: BudgetSlice, fromBudgetWith id: Budget.ID, completion: @escaping (Result<Void, DomainError>) -> Void) {
        storageProvider.fetchBudget(with: id) { result in
            switch result {
            case .success(let budget):
                do {
                    try Budget.canRemove(slice: budgetSlice, from: budget.slices)
                    completion(.success(()))
                } catch {
                    completion(.failure(error as? DomainError ?? .budgetProvider(error: .underlying(error: error))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
