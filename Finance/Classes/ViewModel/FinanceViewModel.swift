//
//  YearlyOverviewViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

@MainActor final class FinanceViewModel: ObservableObject {

    @Published var yearlyOverview: YearlyBudgetOverview

    @Published var selectedMonth: Int = Calendar.current.component(.month, from: .now)

    @Published var isAddNewTransactionPresented: Bool = false
    @Published var isAddNewBudgetPresented: Bool = false

    var month: String {
        return Calendar.current.shortMonthSymbols[selectedMonth - 1]
    }

    var monthlyOverviews: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviews(month: selectedMonth)
    }

    var monthlyOverviewsWithLowestAvailability: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviews(month: selectedMonth)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    var monthlyProspects: [MonthlyProspect] {
        return yearlyOverview.monthlyProspects()
    }

    private let storageProvider: StorageProvider

    // MARK: Object life cycle

    init(year: Int, storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.yearlyOverview = YearlyBudgetOverview(
            name: "Amsterdam",
            year: year,
            openingBalance: .zero,
            budgets: [],
            transactions: []
        )
    }

    // MARK: Internal methods

    func load() async throws {
        let budgets = try await storageProvider.fetchBudgets(year: yearlyOverview.year)
        let transactions = try await storageProvider.fetchTransactions(year: yearlyOverview.year)

        yearlyOverview.set(budgets: budgets)
        yearlyOverview.set(transactions: transactions)
    }

    // MARK: Transactions

    func add(transactions: [Transaction]) async throws {
        try YearlyBudgetOverviewValidator.willAdd(transactions: transactions, for: yearlyOverview.year)
        for transaction in transactions {
            try await storageProvider.add(transaction: transaction)
        }
        try yearlyOverview.append(transactions: transactions)
        isAddNewTransactionPresented = false
    }

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        try await storageProvider.delete(transactionsWith: identifiers)
        yearlyOverview.delete(transactionsWith: identifiers)
    }

    // MARK: Budgets

    func add(budget: Budget) async throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: yearlyOverview.budgets, year: yearlyOverview.year)
        try await storageProvider.add(budget: budget)
        try yearlyOverview.append(budget: budget)
        isAddNewBudgetPresented = false
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        try await storageProvider.delete(budgetsWith: identifiers)
        yearlyOverview.delete(budgetsWith: identifiers)
    }
}

extension FinanceViewModel: BudgetStorageHandler {

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
