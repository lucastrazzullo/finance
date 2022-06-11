//
//  BudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct BudgetOverview: Identifiable {

    var id: UUID {
        budget.id
    }
    var name: String {
        budget.name
    }
    var icon: SystemIcon {
        budget.icon
    }
    var kind: Budget.Kind {
        budget.kind
    }

    var transactionsInMonth: [Transaction] {
        transactions.filter { $0.date.month == month }
    }
    var amount: MoneyValue {
        transactionsInMonth.totalAmount
    }
    var remainingAmount: MoneyValue {
        switch kind {
        case .expense:
            return thresholdAmount + amount
        case .income:
            return thresholdAmount - amount
        }
    }
    var amountPercentage: Float {
        switch kind {
        case .expense:
            return Float(truncating: NSDecimalNumber(decimal: 1 + amount.value / thresholdAmount.value))
        case .income:
            return Float(truncating: NSDecimalNumber(decimal: amount.value / thresholdAmount.value))
        }
    }
    var thresholdAmount: MoneyValue {
        let budgetAvailability = budget.availability(including: month)
        let transactionsUntilMonth = transactions.totalAmount(upTo: month)
        switch kind {
        case .expense:
            return budgetAvailability + transactionsUntilMonth
        case .income:
            return budgetAvailability - transactionsUntilMonth
        }
    }

    private let month: Int
    private let budget: Budget
    private let transactions: [Transaction]

    init(month: Int, budget: Budget, transactions: [Transaction]) {
        self.month = month
        self.budget = budget
        self.transactions = transactions.filter {
            $0.amounts.first {
                $0.budgetIdentifier == budget.id
            } != nil
        }
    }
}
