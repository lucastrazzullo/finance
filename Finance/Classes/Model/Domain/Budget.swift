//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    private static let defaultSliceName: String = "Default"

    let id: UUID
    let name: String
    let slices: [BudgetSlice]

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
            try BudgetSlice(id: .init(), name: Self.defaultSliceName, amount: amount)
        ]
        try self.init(id: id, name: name, slices: slices)
    }

    init(id: ID, name: String, slices: [BudgetSlice]) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        guard !slices.containsDuplicates() else {
            throw DomainError.budget(error: .multipleSlicesWithSameName)
        }

        self.id = id
        self.name = name
        self.slices = slices
    }

    // MARK: Helpers

    static func yearlyAmount(for montlyAmount: MoneyValue) -> MoneyValue {
        montlyAmount * .value(12)
    }

    static func canAdd(slice: BudgetSlice, to list: [BudgetSlice]) throws {
        guard !list.contains(where: { $0.name == slice.name }) else {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: slice.name))
        }
    }

    static func canRemove(slice: BudgetSlice, from slices: [BudgetSlice]) throws {
        guard slices.contains(where: { $0.id == slice.id }) else {
            throw DomainError.budget(error: .sliceDoesntExistWith(name: slice.name))
        }
        guard slices.count > 1 else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
    }
}
