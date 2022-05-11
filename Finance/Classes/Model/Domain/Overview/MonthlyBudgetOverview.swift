//
//  MonthlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct MonthlyBudgetOverview: Hashable {

    var name: String {
        budget?.name ?? "Unowned"
    }
    var icon: SystemIcon {
        budget?.icon ?? .default
    }

    let month: Int
    let budget: Budget?

    let startingAmount: MoneyValue
    let remainingAmount: MoneyValue
    let remainingAmountPercentage: Float

    let expensesUntilMonth: [Transaction]
    let expensesInMonth: [Transaction]

    var totalExpenses: [Transaction] {
        return expensesUntilMonth + expensesInMonth
    }

    init(month: Int, expenses: [Transaction], budget: Budget?) {
        let expensesUntilMonth = expenses
            .filter { transaction in transaction.month < month }

        let expensesInMonth = expenses
            .filter { transaction in transaction.month == month }

        let budgetAvailabilityUpToMonth = budget?.availability(upTo: month) ?? .zero
        let budgetAvailabilityInMonth = budget?.availability(for: month) ?? .zero

        let startingAmount = budgetAvailabilityUpToMonth + budgetAvailabilityInMonth - expensesUntilMonth.totalAmount
        let remainingAmount = startingAmount - expensesInMonth.totalAmount
        let remainingAmountPercentage = remainingAmount.value > 0
            ? Float(truncating: NSDecimalNumber(decimal: 1 - expensesInMonth.totalAmount.value / startingAmount.value))
            : 0

        self.month = month
        self.budget = budget
        self.startingAmount = startingAmount
        self.remainingAmount = remainingAmount
        self.remainingAmountPercentage = remainingAmountPercentage
        self.expensesUntilMonth = expensesUntilMonth
        self.expensesInMonth = expensesInMonth
    }
}
