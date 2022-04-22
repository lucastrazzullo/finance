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
    let totalExpenses: MoneyValue
    let startingAmount: MoneyValue
    let remainingAmount: MoneyValue
    let remainingAmountPercentage: Float

    init(month: Int, budget: Budget, expenses: [Transaction]) {
        let totalExpenses = expenses
            .filter { transaction in transaction.month <= month }
            .filter { transaction in
                budget.slices.contains {
                    $0.id == transaction.budgetSliceId
                }
            }
            .totalAmount

        let startingAmount = budget.availability(upTo: month)
        let remainingAmount = startingAmount - totalExpenses
        let remainingAmountPercentage = startingAmount.value > 0
            ? Float(truncating: NSDecimalNumber(decimal: 1 - totalExpenses.value / startingAmount.value))
            : 0

        self.name = budget.name
        self.icon = budget.icon
        self.totalExpenses = totalExpenses
        self.startingAmount = startingAmount
        self.remainingAmount = remainingAmount
        self.remainingAmountPercentage = remainingAmountPercentage
    }
}
