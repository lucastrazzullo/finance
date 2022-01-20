//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {
    let id: UUID = UUID()
    let name: String
    let slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    init(name: String, slices: [BudgetSlice]) {
        self.name = name
        self.slices = slices
    }

    init(name: String, amount: MoneyValue) {
        self.name = name
        self.slices = [.default(amount: amount)]
    }
}
