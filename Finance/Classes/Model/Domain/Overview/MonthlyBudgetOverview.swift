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

    let transactionsUntilMonth: [Transaction]
    let transactionsInMonth: [Transaction]
    var transactions: [Transaction] {
        return transactionsUntilMonth + transactionsInMonth
    }

    init(month: Int, budget: Budget, transactions: [Transaction]) {
        let transactionsUntilMonth = transactions
            .filter { transaction in transaction.date.month < month }

        let transactionsInMonth = transactions
            .filter { transaction in transaction.date.month == month }

        let budgetAvailabilityUpToMonth = budget.availability(upTo: month)
        let budgetAvailabilityInMonth = budget.availability(for: month)

        let startingAmount = budgetAvailabilityUpToMonth + budgetAvailabilityInMonth + transactionsUntilMonth.totalAmount
        let remainingAmount = startingAmount + transactionsInMonth.totalAmount
        let remainingAmountPercentage = remainingAmount.value > 0
            ? Float(truncating: NSDecimalNumber(decimal: 1 + transactionsInMonth.totalAmount.value / startingAmount.value))
            : 0

        self.month = month
        self.budget = budget
        self.startingAmount = startingAmount
        self.remainingAmount = remainingAmount
        self.remainingAmountPercentage = remainingAmountPercentage
        self.transactionsUntilMonth = transactionsUntilMonth
        self.transactionsInMonth = transactionsInMonth
    }
}
