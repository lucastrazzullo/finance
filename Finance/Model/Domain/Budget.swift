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
        try canAdd(newSlice: newSlice)
        slices.append(newSlice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        try canRemove(slice: slice)
        slices.removeAll(where: { $0.id == slice.id })
    }

    // MARK: Checking methods

    static func canUse(name: String) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
    }

    static func canUse(slices: [BudgetSlice]) throws {
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        if let duplicatedSlice = slices.firstDuplicate() {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: duplicatedSlice.name))
        }
    }

    func canAdd(newSlice: BudgetSlice) throws {
        var newSlices = slices
        newSlices.append(newSlice)
        try Self.canUse(slices: newSlices)
    }

    func canRemove(slice: BudgetSlice) throws {
        guard slices.count > 1 else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        guard slices.contains(where: { $0.id == slice.id }) else {
            throw DomainError.budget(error: .sliceDoesntExist)
        }
    }
}

