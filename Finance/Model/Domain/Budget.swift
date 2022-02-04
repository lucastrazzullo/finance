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
    private(set) var slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
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
        let slices = [
            BudgetSlice.default(amount: amount)
        ]
        try self.init(id: id, name: name, slices: slices)
    }

    init(id: ID, name: String, slices: [BudgetSlice]) throws {
        try Self.canUse(name: name)
        try Self.canUse(slices: slices)

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
        try Self.canAdd(newSlice: newSlice, to: slices)
        slices.append(newSlice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        try Self.canRemove(slice: slice, from: slices)
        slices.removeAll(where: { $0.id == slice.id })
    }

    // MARK: Helpers

    static func yearlyAmount(for montlyAmount: MoneyValue) -> MoneyValue {
        montlyAmount * .value(12)
    }

    // MARK: Checking methods

    static func canUse(name: String) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
    }

    static func canUse(slices: [BudgetSlice]) throws {
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .slicesNotValid(reason: .thereMustBeAtLeastOneSlice))
        }
        if let duplicatedSlice = slices.firstDuplicate() {
            throw DomainError.budget(error: .slicesNotValid(reason: .sliceAlreadyExistsWith(name: duplicatedSlice.name)))
        }
    }

    static func canAdd(newSlice: BudgetSlice, to slices: [BudgetSlice]) throws {
        var newSlices = slices
        newSlices.append(newSlice)
        try Self.canUse(slices: newSlices)
    }

    static func canRemove(slice: BudgetSlice, from slices: [BudgetSlice]) throws {
        guard slices.count > 1 else {
            throw DomainError.budget(error: .slicesNotValid(reason: .thereMustBeAtLeastOneSlice))
        }
        guard slices.contains(where: { $0.id == slice.id }) else {
            throw DomainError.budget(error: .slicesNotValid(reason: .sliceDoesntExist))
        }
    }
}

