//
//  DashboardViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

@MainActor final class DashboardViewModel: ObservableObject {

    @Published var yearlyOverview: YearlyBudgetOverview

    var title: String {
        return yearlyOverview.name
    }

    var subtitle: String {
        return String(yearlyOverview.year)
    }

    var year: Int {
        return yearlyOverview.year
    }

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    var expenses: [Transaction] {
        return yearlyOverview.expenses
    }

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

    // MARK: Internal methods

    func load() async throws {
        yearlyOverview.budgets = try await storageProvider.fetchBudgets(year: yearlyOverview.year)
        yearlyOverview.expenses = try await storageProvider.fetchTransactions(year: yearlyOverview.year)
    }
}

extension DashboardViewModel: BudgetViewModelDelegate {

    func didAdd(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].append(slice: slice)
        }
    }

    func didDelete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws {
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].delete(slicesWith: identifiers)
        }
    }

    func willUpdate(name: String, in budget: Budget) throws {
        try YearlyBudgetOverviewValidator.willUpdate(name: name, for: budget, in: yearlyOverview.budgets)
    }

    func didUpdate(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) throws {
        if let index = yearlyOverview.budgets.firstIndex(where: { $0.id == identifier }) {
            try yearlyOverview.budgets[index].update(name: name)
            try yearlyOverview.budgets[index].update(icon: icon)
        }
    }
}

extension DashboardViewModel: BudgetsListViewModelDelegate {

    func willAdd(budget: Budget) throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets)
    }

    func didAdd(budget: Budget) {
        yearlyOverview.budgets.append(budget)
    }

    func didDelete(budgetsWith identifiers: Set<Budget.ID>) {
        yearlyOverview.budgets.removeAll(where: { identifiers.contains($0.id) })
    }
}

extension DashboardViewModel: OverviewListViewDelegate {

    func willAdd(expenses: [Transaction]) throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: expenses, for: yearlyOverview.year)
    }

    func didAdd(expenses: [Transaction]) {
        yearlyOverview.expenses.append(contentsOf: expenses)
    }
}
