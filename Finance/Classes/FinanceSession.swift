//
//  FinanceSession.swift
//  Finance
//
//  Created by Luca Strazzullo on 16/04/2022.
//

import Foundation

@MainActor final class FinanceSession: ObservableObject {

    // MARK: Instance properties

    @Published var yearlyOverview: YearlyBudgetOverview

    private let storageProvider: StorageProvider

    // MARK: Object life cycle

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.yearlyOverview = YearlyBudgetOverview(
            name: "Default",
            year: 2022,
            budgets: [],
            expenses: []
        )
    }
}

extension FinanceSession: DashboardHandler {

    func load() async throws {
        yearlyOverview.budgets = try await storageProvider.fetchBudgets(year: yearlyOverview.year)
        yearlyOverview.expenses = try await storageProvider.fetchTransactions(year: yearlyOverview.year)
    }
}

extension FinanceSession: BudgetHandler {

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        try await storageProvider.add(slice: slice, toBudgetWith: identifier)
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].append(slice: slice)
        }
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        try await storageProvider.delete(slicesWith: identifiers, inBudgetWith: identifier)
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].delete(slicesWith: identifiers)
        }
    }

    func update(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) async throws {
        guard let budget = yearlyOverview.budgets.with(identifier: identifier) else {
            throw DomainError.budget(error: .cannotFetchTheBudget(id: identifier))
        }
        try YearlyBudgetOverviewValidator.willUpdate(name: name, for: budget, in: yearlyOverview.budgets)
        try await storageProvider.update(name: name, iconSystemName: icon.rawValue, inBudgetWith: identifier)
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].update(name: name)
            try yearlyOverview.budgets[index].update(icon: icon)
        }
    }
}

extension FinanceSession: BudgetsListHandler {

    func add(budget: Budget) async throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets)
        try await storageProvider.add(budget: budget)
        yearlyOverview.budgets.append(budget)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageProvider.delete(budgetsWith: identifiers)
        yearlyOverview.budgets.delete(withIdentifiers: identifiers)
    }
}

extension FinanceSession: OverviewListHandler {

    func add(expenses: [Transaction]) async throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: expenses, for: yearlyOverview.year)

        for expense in expenses {
            try await storageProvider.add(transaction: expense)
        }
        yearlyOverview.expenses.append(contentsOf: expenses)
    }
}
