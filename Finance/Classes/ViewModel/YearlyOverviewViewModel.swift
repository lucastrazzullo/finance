//
//  YearlyOverviewViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

@MainActor final class YearlyOverviewViewModel: ObservableObject {

    @Published var yearlyOverview: YearlyBudgetOverview

    var year: Int {
        return yearlyOverview.year
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

extension YearlyOverviewViewModel: BudgetViewModelDelegate {

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

extension YearlyOverviewViewModel: BudgetsListViewModel {

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    func add(budget: Budget) async throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets, year: year)
        try await storageProvider.add(budget: budget)
        try yearlyOverview.append(budget: budget)
    }

    func delete(budgetsAt offsets: IndexSet) async throws {
        let identifiers = budgets.at(offsets: offsets).map(\.id)
        let identifiersSet = Set(identifiers)
        try await storageProvider.delete(budgetsWith: identifiersSet)
        yearlyOverview.delete(budgetsWith: identifiersSet)
    }
}

extension YearlyOverviewViewModel: TransactionsListViewModel {

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
