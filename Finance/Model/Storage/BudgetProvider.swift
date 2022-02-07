//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol BudgetStorageProvider: AnyObject {

    typealias BudgetListCompletion = (Result<[Budget], DomainError>) -> Void
    typealias BudgetCompletion = (Result<Budget, DomainError>) -> Void

    // MARK: Budget list

    func fetchBudgets(completion: @escaping BudgetListCompletion)
    func add(budget: Budget, completion: @escaping BudgetListCompletion)
    func delete(budget: Budget, completion: @escaping BudgetListCompletion)
    func delete(budgets: [Budget], completion: @escaping BudgetListCompletion)

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID, completion: @escaping BudgetCompletion)
    func updateBudget(budget: Budget, completion: @escaping BudgetCompletion)
}

final class BudgetProvider {

    // MARK: Instance properties

    private let storageProvider: BudgetStorageProvider

    init(storageProvider: BudgetStorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Budget list

    func fetchBudgets() async throws -> [Budget] {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.fetchBudgets { result in
                switch result {
                case .success(let budgets):
                    continuation.resume(returning: budgets)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func add(budget: Budget) async throws -> [Budget] {
        try await canAdd(budget: budget)

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.add(budget: budget) { result in
                switch result {
                case .success(let budgets):
                    continuation.resume(returning: budgets)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func delete(budget: Budget) async throws -> [Budget] {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.delete(budget: budget) { result in
                switch result {
                case .success(let budgets):
                    continuation.resume(returning: budgets)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func delete(budgets: [Budget]) async throws -> [Budget] {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.delete(budgets: budgets) { result in
                switch result {
                case .success(let budgets):
                    continuation.resume(returning: budgets)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Budget

    func fetchBudget(with id: Budget.ID) async throws -> Budget {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.fetchBudget(with: id) { result in
                switch result {
                case .success(let budget):
                    continuation.resume(returning: budget)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func update(budget: Budget) async throws -> Budget {
        try await canUpdate(budget: budget)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.updateBudget(budget: budget) { result in
                switch result {
                case .success(let budget):
                    continuation.resume(returning: budget)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Private helper methods

    private func canAdd(budget: Budget) async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.fetchBudgets { result in
                switch result {
                case .success(let budgets):
                    guard !budgets.contains(where: { $0.name == budget.name }) else {
                        continuation.resume(throwing: DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name)))
                        return
                    }
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func canUpdate(budget: Budget) async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.storageProvider.fetchBudgets { result in
                switch result {
                case .success(let budgets):
                    guard !budgets.contains(where: { $0.id != budget.id && $0.name == budget.name }) else {
                        continuation.resume(throwing: DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name)))
                        return
                    }
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
