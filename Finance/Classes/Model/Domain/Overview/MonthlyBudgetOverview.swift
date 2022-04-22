//
//  MonthlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct MonthlyBudgetOverview: Hashable {

    let name: String
    let icon: SystemIcon

    let startingAmount: MoneyValue
    let remainingAmount: MoneyValue
    let remainingAmountPercentage: Float
    let totalMonthExpenses: MoneyValue

    init(month: Int, budget: Budget, expenses: [Transaction]) {
        let budgetExpenses = expenses.filter { transaction in
            budget.slices.contains {
                $0.id == transaction.budgetSliceId
            }
        }

        let totalExpensesUntilMonth = budgetExpenses
            .filter { transaction in transaction.month < month }
            .totalAmount

        let totalMonthExpenses = expenses
            .filter { transaction in transaction.month == month }
            .totalAmount

        let startingAmount = budget.availability(upTo: month) + budget.availability(for: month) - totalExpensesUntilMonth
        let remainingAmount = startingAmount - totalMonthExpenses
        let remainingAmountPercentage = remainingAmount.value > 0
            ? Float(truncating: NSDecimalNumber(decimal: 1 - totalMonthExpenses.value / startingAmount.value))
            : 0

        self.name = budget.name
        self.icon = budget.icon
        self.startingAmount = startingAmount
        self.remainingAmount = remainingAmount
        self.remainingAmountPercentage = remainingAmountPercentage
        self.totalMonthExpenses = totalMonthExpenses
    }
}
