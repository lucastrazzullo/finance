//
//  YearlyOverviewViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

@MainActor final class YearlyOverviewViewModel: ObservableObject {

    @Published var month: Int = Calendar.current.component(.month, from: .now)
    @Published var addNewTransactionIsPresented: Bool = false
    @Published var yearlyOverview: YearlyBudgetOverview

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

extension YearlyOverviewViewModel: BudgetDataProvider {

    func budget(with identifier: Budget.ID) async throws -> Budget {
        guard let budget = yearlyOverview.budgets.with(identifier: identifier) else {
            throw DomainError.budgetOverview(error: .budgetNotFound)
        }
        return budget
    }

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        try await storageProvider.add(slice: slice, toBudgetWith: identifier)
        try yearlyOverview.append(slice: slice, toBudgetWith: identifier)
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        try await storageProvider.delete(slicesWith: identifiers, inBudgetWith: identifier)
        try yearlyOverview.delete(slicesWith: identifiers, toBudgetWith: identifier)
    }

    func update(name: String, icon: SystemIcon, in budget: Budget) async throws {
        try YearlyBudgetOverviewValidator.willUpdate(name: name, for: budget, in: yearlyOverview.budgets)
        try await storageProvider.update(name: name, iconSystemName: icon.rawValue, inBudgetWith: budget.id)
        try yearlyOverview.update(name: name, icon: icon, inBudgetWith: budget.id)
    }
}

extension YearlyOverviewViewModel: BudgetsListDataProvider {

    var year: Int {
        return yearlyOverview.year
    }

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    func add(budget: Budget) async throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets, year: year)
        try await storageProvider.add(budget: budget)
        try yearlyOverview.append(budget: budget)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageProvider.delete(budgetsWith: identifiers)
        yearlyOverview.delete(budgetsWith: identifiers)
    }
}

extension YearlyOverviewViewModel: TransactionsListViewModel {

    var transactions: [Transaction] {
        return yearlyOverview.expenses
    }

    func add(transactions: [Transaction]) async throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: transactions, for: yearlyOverview.year)
        for transaction in transactions {
            try await storageProvider.add(transaction: transaction)
        }
        try yearlyOverview.append(expenses: transactions)
        addNewTransactionIsPresented = false
    }

    func delete(transactionsAt offsets: IndexSet) async throws {
        let identifiers = transactions.at(offsets: offsets).map(\.id)
        let identifiersSet = Set(identifiers)

        try await storageProvider.delete(transactionsWith: identifiersSet)
        yearlyOverview.delete(expensesWith: identifiersSet)
    }
}
