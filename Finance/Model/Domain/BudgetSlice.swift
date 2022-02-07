//
//  BudgetSlice.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct BudgetSlice: Identifiable, Hashable, AmountHolder {

    let id: UUID
    let name: String
    let amount: MoneyValue

    // MARK: Object life cycle

    init(id: UUID, name: String, amount: String) throws {
        guard let amount = MoneyValue.string(amount) else {
            throw DomainError.budgetSlice(error: .amountNotValid)
        }

        try self.init(id: id, name: name, amount: amount)
    }

    init(id: UUID, name: String, amount: MoneyValue) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetSlice(error: .nameNotValid)
        }

        self.id = id
        self.name = name
        self.amount = amount
    }

    // MARK: Hashable conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount.value)
    }
}

extension Array where Element == BudgetSlice {

    func containsDuplicates() -> Bool {
        let allNames = self.map(\.name)
        let uniqueNames = Set(allNames)
        return allNames.count > uniqueNames.count
    }
}
