//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, Hashable, AmountHolder {

    typealias ID = UUID

    private static let defaultSliceName: String = "Default"

    let id: ID
    let year: Int

    private(set) var icon: SystemIcon
    private(set) var name: String
    private(set) var slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    // MARK: Object life cycle

    init(id: ID, year: Int, name: String, icon: SystemIcon, monthlyAmount: MoneyValue) throws {
        let slices = [
            try BudgetSlice(id: .init(), name: Self.defaultSliceName, configuration: .monthly(amount: monthlyAmount))
        ]
        try self.init(id: id, year: year, name: name, icon: icon, slices: slices)
    }

    init(id: ID, year: Int, name: String, icon: SystemIcon, slices: [BudgetSlice]) throws {
        try BudgetValidator.canUse(name: name)
        try BudgetValidator.canUse(slices: slices)

        self.id = id
        self.year = year
        self.icon = icon
        self.name = name
        self.slices = slices
    }

    // MARK: Getters

    func availability(upTo month: Int) -> MoneyValue {
        slices.reduce(MoneyValue.zero) { accumulatedAmount, slice in
                switch slice.configuration {
                case .monthly(let amount):
                    return accumulatedAmount + (amount * .value(Decimal(month - 1)))
                case .scheduled(let schedules):
                    return accumulatedAmount + schedules.filter({ $0.month < month }).totalAmount
                }
            }
    }

    func availability(for month: Int) -> MoneyValue {
        slices.reduce(MoneyValue.zero) { accumulatedAmount, slice in
                switch slice.configuration {
                case .monthly(let amount):
                    return accumulatedAmount + amount
                case .scheduled(let schedules):
                    return accumulatedAmount + schedules.filter({ $0.month == month }).totalAmount
                }
            }
    }

    func slices(at offsets: IndexSet) -> [BudgetSlice] {
        return slices
            .enumerated()
            .filter({ index, slice in offsets.contains(index) })
            .map(\.element)
    }

    // MARK: Mutating methods

    mutating func update(name: String) throws {
        try BudgetValidator.canUse(name: name)
        self.name = name
    }

    mutating func update(icon: SystemIcon) throws {
        self.icon = icon
    }

    mutating func append(slice: BudgetSlice) throws {
        try BudgetValidator.willAdd(slice: slice, to: slices)
        slices.append(slice)
    }

    mutating func delete(slicesWith identifiers: Set<BudgetSlice.ID>) throws {
        try BudgetValidator.willDelete(slicesWith: identifiers, from: slices)
        slices.removeAll(where: { identifiers.contains($0.id) })
    }
}

extension Array where Element == Budget {

    func with(identifiers: Set<Budget.ID>) -> [Budget] {
        return self.filter({ identifiers.contains($0.id) })
    }

    func with(identifier: Budget.ID) -> Budget? {
        return self.first(where: { $0.id == identifier })
    }

    func at(offsets: IndexSet) -> [Budget] {
        return NSArray(array: self).objects(at: offsets) as? [Budget] ?? []
    }

    func at(index: Int) -> Budget? {
        guard self.indices.contains(index) else {
            return nil
        }
        return self[index]
    }

    mutating func delete(withIdentifier identifier: Budget.ID) {
        self.removeAll(where: { $0.id == identifier })
    }

    mutating func delete(withIdentifiers identifiers: Set<Budget.ID>) {
        self.removeAll(where: { identifiers.contains($0.id) })
    }
}
