//
//  MonthlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct MonthlyBudgetOverview: Identifiable {

    var id: UUID {
        budget.id
    }
    var name: String {
        budget.name
    }
    var icon: SystemIcon {
        budget.icon
    }

    let month: Int
    let budget: Budget

    let startingAmount: MoneyValue
    let remainingAmount: MoneyValue
    let remainingAmountPercentage: Float

    let expensesUntilMonth: [Transaction]
    let expensesInMonth: [Transaction]

    var totalExpenses: [Transaction] {
        return expensesUntilMonth + expensesInMonth
    }

    init(month: Int, budget: Budget, expenses: [Transaction]) {
        let expensesUntilMonth = expenses
            .filter { transaction in transaction.month < month }

        let expensesInMonth = expenses
            .filter { transaction in transaction.month == month }

        let budgetAvailabilityUpToMonth = budget.availability(upTo: month)
        let budgetAvailabilityInMonth = budget.availability(for: month)

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
