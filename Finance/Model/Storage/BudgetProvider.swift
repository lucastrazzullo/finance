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
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.canAdd(budget: budget) { [weak self] result in
                switch result {
                case .success:
                    self?.storageProvider.add(budget: budget) { result in
                        switch result {
                        case .success(let budgets):
                            continuation.resume(returning: budgets)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
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
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.canUpdate(budget: budget) { [weak self] result in
                switch result {
                case .success:
                    self?.storageProvider.updateBudget(budget: budget) { result in
                        switch result {
                        case .success(let budget):
                            continuation.resume(returning: budget)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
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
