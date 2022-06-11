//
//  YearlyOverviewViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol FinanceStorageHandler: AnyObject {
    func fetchTransactions(year: Int) async throws -> [Transaction]
    func fetchBudgets(year: Int) async throws -> [Budget]

    func add(transactions: [Transaction], for year: Int) async throws
    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws

    func add(budget: Budget, for year: Int) async throws
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws
}

@MainActor final class FinanceViewModel: ObservableObject {

    @Published var yearlyOverview: YearlyOverview
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: .now)

    @Published var isAddNewTransactionPresented: Bool = false
    @Published var isAddNewBudgetPresented: Bool = false

    var month: String {
        return Calendar.current.shortMonthSymbols[selectedMonth - 1]
    }

    var currentBalance: MoneyValue {
        return yearlyOverview.balance(including: selectedMonth)
    }

    var budgetOverviews: [BudgetOverview] {
        return yearlyOverview.budgetOverviews(month: selectedMonth)
    }

    var monthlyOverviews: [MonthlyOverview] {
        return yearlyOverview.monthlyOverviews()
    }

    private let storageHandler: FinanceStorageHandler

    // MARK: Object life cycle

    init(year: Int, openingBalance: MoneyValue, storageHandler: FinanceStorageHandler) {
        self.storageHandler = storageHandler
        self.yearlyOverview = YearlyOverview(
            name: "Amsterdam",
            year: year,
            openingBalance: openingBalance,
            budgets: [],
            transactions: []
        )
    }

    // MARK: Internal methods

    func load() async throws {
        let budgets = try await storageHandler.fetchBudgets(year: yearlyOverview.year)
        let transactions = try await storageHandler.fetchTransactions(year: yearlyOverview.year)

        yearlyOverview.set(budgets: budgets)
        yearlyOverview.set(transactions: transactions)
    }

    // MARK: Transactions

    func add(transactions: [Transaction]) async throws {
        try await storageHandler.add(transactions: transactions, for: yearlyOverview.year)
        try yearlyOverview.append(transactions: transactions)
        isAddNewTransactionPresented = false
    }

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        try await storageHandler.delete(transactionsWith: identifiers)
        yearlyOverview.delete(transactionsWith: identifiers)
    }

    // MARK: Budgets

    func add(budget: Budget) async throws {
        try await storageHandler.add(budget: budget, for: yearlyOverview.year)
        try yearlyOverview.append(budget: budget)
        isAddNewBudgetPresented = false
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageHandler.delete(budgetsWith: identifiers)
        yearlyOverview.delete(budgetsWith: identifiers)
    }
}
