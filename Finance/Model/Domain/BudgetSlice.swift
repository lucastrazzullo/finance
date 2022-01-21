//
//  BudgetSlice.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct BudgetSlice: Identifiable, Hashable, AmountHolder {
    let id: UUID = .init()
    let name: String
    let amount: MoneyValue
    let budgetId: Budget.ID

    static func `default`(amount: MoneyValue, budgetId: Budget.ID) -> Self {
        BudgetSlice(name: "Default", amount: amount, budgetId: budgetId)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount.value)
        hasher.combine(budgetId)
    }
}
