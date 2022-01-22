//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    let id: UUID
    let name: String
    let slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    init(id: ID, name: String, amount: MoneyValue = .zero) {
        self.init(id: id, name: name, slices: [.default(amount: amount)])
    }

    init(id: ID, name: String, slices: [BudgetSlice]) {
        self.id = id
        self.name = name
        self.slices = slices
    }
}

extension Budget {

    static func with(budgetEntity: BudgetEntity) -> Self? {
        guard let identifier = budgetEntity.identifier,
              let name = budgetEntity.name,
              let slices = budgetEntity.slices else {
            return nil
        }

        let budgetSlices = slices
            .compactMap { $0 as? BudgetSliceEntity }
            .compactMap { BudgetSlice.with(budgetSliceEntity: $0) }

        return Budget(id: identifier, name: name, slices: budgetSlices)
    }
}
