//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    struct Slice {
        let name: String
        let amount: MoneyValue
    }

    let id: UUID
    let name: String
    let slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    init(name: String, amount: MoneyValue = .zero) {
        self.id = UUID()
        self.name = name
        self.slices = [.default(amount: amount, budgetId: id)]
    }

    private init(id: ID, name: String, slices: [BudgetSlice]) {
        self.id = id
        self.name = name
        self.slices = slices
    }

    func sliced(in slices: [Slice]) -> Self {
        let slices = slices.map { slice in
            BudgetSlice(name: slice.name, amount: slice.amount, budgetId: id)
        }

        return Self.init(id: id, name: name, slices: slices)
    }
}
