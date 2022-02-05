//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    let id: UUID

    private(set) var name: String
    private(set) var slices: BudgetSlices

    var amount: MoneyValue {
        return slices.amount
    }

    var yearlyAmount: MoneyValue {
        return Self.yearlyAmount(for: amount)
    }

    // MARK: Object life cycle

    init(id: ID, name: String, amount: String) throws {
        guard let amount = MoneyValue.string(amount) else {
            throw DomainError.budget(error: .amountNotValid)
        }
        try self.init(id: id, name: name, amount: amount)
    }

    init(id: ID, name: String, amount: MoneyValue = .zero) throws {
        let slices = try BudgetSlices(list: [
            BudgetSlice.default(amount: amount)
        ])
        try self.init(id: id, name: name, slices: slices)
    }

    init(id: ID, name: String, slices: BudgetSlices) throws {
        try Self.canUse(name: name)

        self.id = id
        self.name = name
        self.slices = slices
    }

    // MARK: Mutating methods

    mutating func update(name newName: String) throws {
        try Self.canUse(name: newName)
        name = newName
    }

    mutating func add(newSlice: BudgetSlice) throws {
        try slices.add(newSlice: newSlice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        try slices.remove(slice: slice)
    }

    // MARK: Helpers

    static func yearlyAmount(for montlyAmount: MoneyValue) -> MoneyValue {
        montlyAmount * .value(12)
    }

    // MARK: Checking methods

    private static func canUse(name: String) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
    }
}
