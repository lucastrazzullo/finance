//
//  YearlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct YearlyBudgetOverview: Identifiable {

    let id: UUID = .init()
    let name: String
    let year: Int
    let openingBalance: MoneyValue

    private(set) var budgets: [Budget]
    private(set) var transactions: [Transaction]

    // MARK: Object life cycle

    init(name: String, year: Int, openingBalance: MoneyValue, budgets: [Budget], transactions: [Transaction]) {
        let budgets = budgets.filter { $0.year == year }
        let transactions = transactions.filter { $0.date.year == year }

        self.name = name
        self.year = year
        self.openingBalance = openingBalance
        self.budgets = budgets
        self.transactions = transactions
    }

    // MARK: Getters

    func monthlyOverviews(month: Int) -> [MonthlyBudgetOverview] {
        return budgets
            .compactMap { budget -> MonthlyBudgetOverview? in
                let budgetSlicesIdentifiers = Set(budget.slices.map(\.id))
                let budgetTransactions = transactions.filter { transaction in
                    let transactionSlicesIdentifiers = Set(transaction.amounts.map(\.sliceIdentifier))
                    return !budgetSlicesIdentifiers.intersection(transactionSlicesIdentifiers).isEmpty
                }

                return MonthlyBudgetOverview(month: month, budget: budget, transactions: budgetTransactions)
            }
            .sorted {
                $0.transactionsInMonth.totalAmount > $1.transactionsInMonth.totalAmount
            }
    }

    func monthlyProspects() -> [MonthlyProspect] {
        return (1...12)
            .compactMap { month -> MonthlyProspect? in
                return MonthlyProspect(year: year, month: month, openingYearBalance: openingBalance, transactions: transactions, budgets: budgets)
            }
    }

    // MARK: Mutating - Budgets

    mutating func set(budgets: [Budget]) {
        self.budgets = budgets.filter { $0.year == year }
    }

    mutating func append(budget: Budget) throws {
        try YearlyBudgetOverviewValidator.willAdd(budget: budget, to: budgets, year: year)
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
        try YearlyBudgetOverviewValidator.willAdd(transactions: transactions, for: year)
        self.transactions.append(contentsOf: transactions)
    }

    mutating func delete(transactionsWith identifiers: Set<Budget.ID>) {
        transactions.removeAll(where: { identifiers.contains($0.id) })
    }
}
