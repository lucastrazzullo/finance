//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol BudgetStorageProvider: AnyObject {

    // MARK: Budget list

    func fetchBudgets() async throws -> [Budget]
    func add(budget: Budget) async throws -> [Budget]
    func delete(budget: Budget) async throws -> [Budget]
    func delete(budgets: [Budget]) async throws -> [Budget]

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID) async throws -> Budget
    func updateBudget(budget: Budget) async throws -> Budget
}

final actor BudgetProvider {

    // MARK: Instance properties

    private let storageProvider: BudgetStorageProvider

    init(storageProvider: BudgetStorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Budget list

    func fetchBudgets() async throws -> [Budget] {
        return try await storageProvider.fetchBudgets()
    }

    func add(budget: Budget) async throws -> [Budget] {
        try await canAdd(budget: budget)
        return try await storageProvider.add(budget: budget)
    }

    func delete(budget: Budget) async throws -> [Budget] {
        return try await storageProvider.delete(budget: budget)
    }

    func delete(budgets: [Budget]) async throws -> [Budget] {
        return try await storageProvider.delete(budgets: budgets)
    }

    private func canAdd(budget: Budget) async throws {
        let budgets = try await storageProvider.fetchBudgets()

        guard !budgets.contains(where: { $0.name == budget.name }) else {
            throw DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }

    // MARK: Budget

    func fetchBudget(with id: Budget.ID) async throws -> Budget {
        return try await storageProvider.fetchBudget(with: id)
    }

    func update(budget: Budget) async throws -> Budget {
        try await canUpdate(budget: budget)
        return try await storageProvider.updateBudget(budget: budget)
    }

    private func canUpdate(budget: Budget) async throws {
        let budgets = try await storageProvider.fetchBudgets()

        guard !budgets.contains(where: { $0.id != budget.id && $0.name == budget.name }) else {
            throw DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }
}
