//
//  Finance.swift
//  Finance
//
//  Created by Luca Strazzullo on 30/05/2022.
//

import Foundation

final class Finance: ObservableObject {

    private let storageProvider: StorageProvider

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
}

extension Finance: FinanceStorageHandler {

    // MARK: Transactions

    func fetchTransactions(year: Int) async throws -> [Transaction] {
        return try await storageProvider.fetchTransactions(year: year)
    }

    func add(transactions: [Transaction], for year: Int) async throws {
        try YearlyBudgetOverviewValidator.willAdd(transactions: transactions, for: year)
        for transaction in transactions {
            try await storageProvider.add(transaction: transaction)
        }
    }

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        try await storageProvider.delete(transactionsWith: identifiers)
    }

    // MARK: Budgets

    func fetchBudget(with identifier: Budget.ID) async throws -> Budget {
        return try await storageProvider.fetchBudget(with: identifier)
    }

    func fetchBudgets(year: Int) async throws -> [Budget] {
        return try await storageProvider.fetchBudgets(year: year)
    }

    func add(budget: Budget, for year: Int) async throws {
        let budgets = try await fetchBudgets(year: year)
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: budgets, year: year)
        try await storageProvider.add(budget: budget)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageProvider.delete(budgetsWith: identifiers)
    }
}

extension Finance: BudgetStorageHandler {

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        let budget = try await storageProvider.fetchBudget(with: identifier)
        try BudgetValidator.willAdd(slice: slice, to: budget.slices)
        try await storageProvider.add(slice: slice, toBudgetWith: identifier)
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        let budget = try await storageProvider.fetchBudget(with: identifier)
        try BudgetValidator.willDelete(slicesWith: identifiers, from: budget.slices)
        try await storageProvider.delete(slicesWith: identifiers, inBudgetWith: identifier)
    }

    func update(name: String, icon: SystemIcon, in budget: Budget) async throws {
        try BudgetValidator.canUse(name: name)
        let budgets = try await storageProvider.fetchBudgets(year: budget.year)
        try YearlyBudgetOverviewValidator.willUpdate(name: name, for: budget, in: budgets)
        try await storageProvider.update(name: name, iconSystemName: icon.rawValue, inBudgetWith: budget.id)
    }
}
