//
//  Transaction.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Transaction: Identifiable, AmountHolder {

    enum TransactionType: String, CaseIterable {
        case expense
        case income
    }

    let id: UUID = UUID()
    let date: Date = Date()
    let amount: MoneyValue
    let type: TransactionType
    let description: String?
    let budgetId: Budget.ID
    let budgetSliceId: BudgetSlice.ID

    init(amount: MoneyValue, type: TransactionType, description: String? = nil, budgetId: Budget.ID, budgetSliceId: BudgetSlice.ID) {
        self.amount = amount
        self.type = type
        self.description = description
        self.budgetId = budgetId
        self.budgetSliceId = budgetSliceId
    }
}
