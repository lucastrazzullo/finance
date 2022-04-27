//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

final class MockStorageProvider: StorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var transactions: [Transaction]
    private var budgets: [Budget]

    // MARK: Object life cycle

    init() {
        self.transactions = []
        self.budgets = []
    }

    init(budgets: [Budget], transactions: [Transaction]) {
        self.transactions = transactions
        self.budgets = budgets
    }

    // MARK: Fetch

    func fetchBudgets(year: Int) async throws -> [Budget] {
        return budgets.filter { budget in
            budget.year == year
        }
    }

    func fetchTransactions(year: Int) async throws -> [Transaction] {
        return transactions.filter { transaction in
            transaction.date.year == year
        }
    }

    // MARK: Add

    func add(transaction: Transaction) async throws {
        self.transactions.append(transaction)
    }

    func add(budget: Budget) async throws {
        self.budgets.append(budget)
    }

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].append(slice: slice)
        }
    }

    // MARK: Delete

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        transactions.removeAll(where: { identifiers.contains($0.id) })
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].delete(slicesWith: identifiers)
        }
    }

    // MARK: Update

    func update(name: String, iconSystemName: String, inBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].update(name: name)
            try budgets[index].update(icon: SystemIcon(rawValue: iconSystemName)!)
        }
    }
}
