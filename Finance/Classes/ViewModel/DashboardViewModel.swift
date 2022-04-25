//
//  DashboardViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

@MainActor final class DashboardViewModel: ObservableObject {

    @Published var yearlyOverview: YearlyBudgetOverview

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

    init(year: Int, storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.yearlyOverview = YearlyBudgetOverview(
            name: "Default",
            year: year,
            budgets: [],
            expenses: []
        )
    }

    // MARK: Internal methods

    func load() async throws {
        let budgets = try await storageProvider.fetchBudgets(year: yearlyOverview.year)
        let expenses = try await storageProvider.fetchTransactions(year: yearlyOverview.year)

        yearlyOverview.set(budgets: budgets)
        yearlyOverview.set(expenses: expenses)
    }
}

extension DashboardViewModel: BudgetViewModelDelegate {

    func didAdd(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        try yearlyOverview.append(slice: slice, toBudgetWith: identifier)
    }

    func didDelete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws {
        try yearlyOverview.delete(slicesWith: identifiers, toBudgetWith: identifier)
    }

    func willUpdate(name: String, in budget: Budget) throws {
        try YearlyBudgetOverviewValidator.willUpdate(name: name, for: budget, in: yearlyOverview.budgets)
    }

    func didUpdate(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) throws {
        try yearlyOverview.update(name: name, icon: icon, inBudgetWith: identifier)
    }
}

extension DashboardViewModel: BudgetsListViewModelDelegate {

    func willAdd(budget: Budget) throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets, year: year)
    }

    func didAdd(budget: Budget) throws {
        try yearlyOverview.append(budget: budget)
    }

    func didDelete(budgetsWith identifiers: Set<Budget.ID>) {
        yearlyOverview.delete(budgetsWith: identifiers)
    }
}

extension DashboardViewModel: TransactionsListViewModel {

    var transactions: [Transaction] {
        return expenses
    }

    func add(transactions: [Transaction]) async throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: transactions, for: yearlyOverview.year)
        for transaction in transactions {
            try await storageProvider.add(transaction: transaction)
        }
        try yearlyOverview.append(expenses: transactions)
    }

    func delete(transactionsAt offsets: IndexSet) async throws {
        let identifiers = transactions.at(offsets: offsets).map(\.id)
        let identifiersSet = Set(identifiers)

        try await storageProvider.delete(transactionsWith: identifiersSet)
        yearlyOverview.delete(expensesWith: identifiersSet)
    }
}
