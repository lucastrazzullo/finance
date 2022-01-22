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

    static func `default`(amount: MoneyValue) -> Self {
        BudgetSlice(name: "Default", amount: amount)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount.value)
    }
}

extension BudgetSlice {

    static func with(budgetSliceEntity: BudgetSliceEntity) -> Self? {
        guard let name = budgetSliceEntity.name,
              let amountDecimal = budgetSliceEntity.amount else {
            return nil
        }

        return BudgetSlice(name: name, amount: .value(amountDecimal.decimalValue))
    }
}
