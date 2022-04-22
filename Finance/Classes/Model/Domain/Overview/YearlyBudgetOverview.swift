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

    func monthlyOverviews(month: Int) -> [MonthlyBudgetOverview] {
        var overviews = budgets
            .filter { $0.year == year }
            .compactMap { budget in
                MonthlyBudgetOverview(month: month, expenses: expenses, budget: budget)
            }

        let allSlicesIdentifiers = budgets.flatMap({ $0.slices.map(\.id) })
        let unownedExpenses = expenses.filter { transaction in !allSlicesIdentifiers.contains(transaction.budgetSliceId) }
        if unownedExpenses.count > 0 {
            let unownedOverview = MonthlyBudgetOverview(month: month, expenses: unownedExpenses, budget: nil)
            overviews.append(unownedOverview)
        }

        return overviews
    }

    func monthlyOverviewsWithLowestAvailability(month: Int) -> [MonthlyBudgetOverview] {
        monthlyOverviews(month: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    // MARK: Mutating

    mutating func set(budgets: [Budget]) {
        self.budgets = budgets.filter { $0.year == year }
    }

    mutating func set(expenses: [Transaction]) {
        self.expenses = expenses.filter { $0.year == year }
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

    mutating func append(expenses: [Transaction]) throws {
        try YearlyBudgetOverviewValidator.willAdd(expenses: expenses, for: year)
        self.expenses.append(contentsOf: expenses)
    }
}
