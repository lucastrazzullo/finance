//
//  FinanceSession.swift
//  Finance
//
//  Created by Luca Strazzullo on 16/04/2022.
//

import Foundation

@MainActor final class FinanceSession: ObservableObject {

    // MARK: Instance properties

    @Published var overview: YearlyBudgetOverview

    private let storageProvider: StorageProvider

    // MARK: Object life cycle

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.overview = YearlyBudgetOverview.empty
    }

    // MARK: Reload

    func load() async throws {
        let transactions = try await storageProvider.fetchTransactions(year: overview.year)
        let budgets = try await storageProvider.fetchBudgets(year: overview.year)

        try overview.set(transactions: transactions)
        try overview.set(budgets: budgets)
    }

    // MARK: Add

    func add(transactions: [Transaction]) async throws {
        for transaction in transactions {
            try overview.willAdd(transactions: transactions)
            try await storageProvider.add(transaction: transaction)
        }
        try overview.append(transactions: transactions)
    }

    func add(budget: Budget) async throws {
        try overview.willAdd(budget: budget)
        try await storageProvider.add(budget: budget)
        try overview.append(budget: budget)
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        try overview.willAdd(slice: slice, toBudgetWith: id)
        try await storageProvider.add(slice: slice, toBudgetWith: id)
        try overview.append(slice: slice, toBudgetWith: id)
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageProvider.delete(budgetsWith: identifiers)
        overview.delete(budgetsWithIdentifiers: identifiers)
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        try overview.willDelete(slicesWith: identifiers, inBudgetWith: identifier)
        try await storageProvider.delete(slicesWith: identifiers, inBudgetWith: identifier)
        try overview.delete(slicesWith: identifiers, inBudgetWith: identifier)
    }

    // MARK: Update

    func update(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) async throws {
        try overview.willUpdate(name: name, forBudgetWith: identifier)
        try await storageProvider.update(name: name, iconSystemName: icon.rawValue, inBudgetWith: identifier)
        try overview.update(name: name, icon: icon, forBudgetWith: identifier)
    }
}
