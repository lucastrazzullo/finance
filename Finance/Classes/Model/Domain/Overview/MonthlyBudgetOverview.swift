//
//  MonthlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct MonthlyBudgetOverview: Hashable {

    let month: Int
    let name: String
    let icon: SystemIcon

    let startingAmount: MoneyValue
    let remainingAmount: MoneyValue
    let remainingAmountPercentage: Float

    let expensesUntilMonth: [Transaction]
    let expensesInMonth: [Transaction]

    var totalExpenses: [Transaction] {
        return expensesUntilMonth + expensesInMonth
    }

    init(month: Int, expenses: [Transaction], budget: Budget?) {
        let filteredExpenses: [Transaction]
        if let budget = budget {
            let budgetSlicesIdentifiers = Set(budget.slices.map(\.id))
            filteredExpenses = expenses.filter { transaction in
                let transactionSlicesIdentifiers = Set(transaction.amounts.map(\.sliceIdentifier))
                return !budgetSlicesIdentifiers.intersection(transactionSlicesIdentifiers).isEmpty
            }
        } else {
            filteredExpenses = expenses
        }


        let expensesUntilMonth = filteredExpenses
            .filter { transaction in transaction.month < month }

        let expensesInMonth = filteredExpenses
            .filter { transaction in transaction.month == month }

        let budgetAvailabilityUpToMonth = budget?.availability(upTo: month) ?? .zero
        let budgetAvailabilityInMonth = budget?.availability(for: month) ?? .zero

        let startingAmount = budgetAvailabilityUpToMonth + budgetAvailabilityInMonth - expensesUntilMonth.totalAmount
        let remainingAmount = startingAmount - expensesInMonth.totalAmount
        let remainingAmountPercentage = remainingAmount.value > 0
            ? Float(truncating: NSDecimalNumber(decimal: 1 - expensesInMonth.totalAmount.value / startingAmount.value))
            : 0

        self.month = month
        self.name = budget?.name ?? "Unowned"
        self.icon = budget?.icon ?? .default
        self.startingAmount = startingAmount
        self.remainingAmount = remainingAmount
        self.remainingAmountPercentage = remainingAmountPercentage
        self.expensesUntilMonth = expensesUntilMonth
        self.expensesInMonth = expensesInMonth
    }
}
