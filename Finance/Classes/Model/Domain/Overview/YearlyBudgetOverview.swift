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

    private(set) var budgets: [Budget]
    private(set) var expenses: [Transaction]

    // MARK: Object life cycle

    init(name: String, year: Int, budgets: [Budget], expenses: [Transaction]) {
        let budgets = budgets.filter { $0.year == year }
        let expenses = expenses.filter { $0.year == year }

        self.name = name
        self.year = year
        self.budgets = budgets
        self.expenses = expenses
    }

    // MARK: Getters

    func monthlyOverviewsWithLowestAvailability(month: Int) -> [MonthlyBudgetOverview] {
        return monthlyOverviews(month: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    func monthlyOverviews(month: Int) -> [MonthlyBudgetOverview] {
        return budgets.compactMap { budget -> MonthlyBudgetOverview in
            let budgetSlicesIdentifiers = Set(budget.slices.map(\.id))
            let budgetExpenses = expenses.filter { transaction in
                let transactionSlicesIdentifiers = Set(transaction.amounts.map(\.sliceIdentifier))
                return !budgetSlicesIdentifiers.intersection(transactionSlicesIdentifiers).isEmpty
            }

            return MonthlyBudgetOverview(month: month, budget: budget, expenses: budgetExpenses)
        }
        .sorted(by: { $0.expensesInMonth.totalAmount > $1.expensesInMonth.totalAmount })
    }

    func monthlyProspects() -> [MonthlyProspect] {
        return (1...12)
            .compactMap { month -> MonthlyProspect in
                return MonthlyProspect(month: month)
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

    mutating func set(expenses: [Transaction]) {
        self.expenses = expenses.filter { $0.year == year }
    }

    mutating func append(expenses: [Transaction]) throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: expenses, for: year)
        self.expenses.append(contentsOf: expenses)
    }

    mutating func delete(expensesWith identifiers: Set<Budget.ID>) {
        expenses.removeAll(where: { identifiers.contains($0.id) })
    }
}
