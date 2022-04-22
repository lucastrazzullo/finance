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

    var budgets: [Budget]
    var expenses: [Transaction]

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
        budgets
            .filter { $0.year == year }
            .compactMap { budget in
                MonthlyBudgetOverview(month: month, budget: budget, expenses: expenses)
            }
    }

    func monthlyOverviewsWithLowestAvailability(month: Int) -> [MonthlyBudgetOverview] {
        monthlyOverviews(month: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }
}
