//
//  YearlyOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct YearlyOverview: Identifiable {

    let id: UUID = .init()
    let name: String
    let year: Int
    let openingBalance: MoneyValue

    private(set) var budgets: [Budget]
    private(set) var transactions: [Transaction]

    // MARK: Object life cycle

    init(name: String, year: Int, openingBalance: MoneyValue, budgets: [Budget], transactions: [Transaction]) {
        self.budgets = budgets.filter { $0.year == year }
        self.transactions = transactions.filter { $0.date.year == year }


        self.name = name
        self.year = year
        self.openingBalance = openingBalance
    }

    // MARK: Getters

    func balance(including month: Int) -> MoneyValue {
        return openingBalance + transactions.totalAmount(including: month)
    }

    func budgetOverviews(month: Int) -> [BudgetOverview] {
        return budgets
            .compactMap { budget -> BudgetOverview? in
                BudgetOverview(month: month, budget: budget, transactions: transactions)
            }
            .sorted { lhs, rhs in
                lhs.transactionsInMonth.totalAmount > rhs.transactionsInMonth.totalAmount
            }
    }

    func monthlyOverviews() -> [MonthlyOverview] {
        return (1...12)
            .compactMap { month -> MonthlyOverview? in
                return MonthlyOverview(month: month, openingBalance: openingBalance, transactions: transactions, budgets: budgets)
            }
    }

    // MARK: Mutating - Budgets

    mutating func set(budgets: [Budget]) {
        self.budgets = budgets.filter { $0.year == year }
    }

    mutating func append(budget: Budget) throws {
        try YearlyOverviewValidator.willAdd(budget: budget, to: budgets, year: year)
        self.budgets.append(budget)
    }

    mutating func delete(budgetsWith identifiers: Set<Budget.ID>) {
        budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    mutating func append(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].append(slice: slice)
        }
    }

    mutating func delete(slicesWith identifiers: Set<BudgetSlice.ID>, toBudgetWith identifier: Budget.ID) throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].delete(slicesWith: identifiers)
        }
    }

    mutating func update(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].update(name: name)
            try budgets[index].update(icon: icon)
        }
    }

    // MARK: Mutating - Expenses

    mutating func set(transactions: [Transaction]) {
        self.transactions = transactions.filter { $0.date.year == year }
    }

    mutating func append(transactions: [Transaction]) throws {
        try YearlyOverviewValidator.willAdd(transactions: transactions, for: year)
        self.transactions.append(contentsOf: transactions)
    }

    mutating func delete(transactionsWith identifiers: Set<Budget.ID>) {
        transactions.removeAll(where: { identifiers.contains($0.id) })
    }
}
