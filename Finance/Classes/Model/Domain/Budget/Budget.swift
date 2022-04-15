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
    private(set) var icon: Icon
    private(set) var name: String
    private(set) var slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    // MARK: Object life cycle

    init(id: ID = .init(), year: Int, name: String, icon: Icon, monthlyAmount: MoneyValue) throws {
        let slices = [
            try BudgetSlice(id: .init(), name: Self.defaultSliceName, configuration: .monthly(amount: monthlyAmount))
        ]
        try self.init(id: id, year: year, name: name, icon: icon, slices: slices)
    }

    init(id: ID = .init(), year: Int, name: String, icon: Icon, slices: [BudgetSlice]) throws {
        try Self.canUse(name: name)
        try Self.canUse(slices: slices)

        self.id = id
        self.year = year
        self.icon = icon
        self.name = name
        self.slices = slices
    }

    // MARK: Getters

    func availability(upTo month: Int) -> MoneyValue {
        slices
            .reduce(MoneyValue.zero) { accumulatedAmount, slice in
                switch slice.configuration {
                case .monthly(let amount):
                    return accumulatedAmount + (amount * .value(Decimal(month)))
                case .scheduled(let schedules):
                    return accumulatedAmount + schedules.filter({ $0.month <= month }).totalAmount
                }
            }
    }

    func sliceIdentifiers(at indices: IndexSet) -> Set<BudgetSlice.ID> {
        return Set(slices(at: indices).map(\.id))
    }

    func slices(at indices: IndexSet) -> [BudgetSlice] {
        return slices
            .enumerated()
            .filter({ index, slice in indices.contains(index) })
            .map(\.element)
    }

    // MARK: Mutating methods

    /// Updates name in budget
    /// Parameters:
    ///     - name: New name of the budget
    ///
    mutating func update(name: String) throws {
        try willUpdate(name: name)
        self.name = name
    }

    /// Updates the icon for the budget
    /// Parameters:
    ///     - iconSystemName: The system name of an SFSymbol
    ///
    mutating func update(icon: Icon) throws {
        self.icon = icon
    }

    /// Appends a slice to the list
    /// Parameters:
    ///     - slice: Slice to append
    ///     - throws: This method checks whether the slices can be added based on the business logic defined in Budget
    ///
    mutating func append(slice: BudgetSlice) throws {
        try willAdd(slice: slice)
        slices.append(slice)
    }

    /// Deletes slices at offsets
    /// Parameters:
    ///     - offsets: Offsets of slices to delete
    ///     - throws: This method checks whether the slices can be removed based on the business logic defined in Budget
    ///
    mutating func delete(slicesAt indices: IndexSet) throws {
        var updatedSlices = slices
        updatedSlices.remove(atOffsets: indices)
        try Self.canUse(slices: updatedSlices)
        slices = updatedSlices
    }

    // MARK: Helpers

    func willUpdate(name: String) throws {
        try Self.canUse(name: name)
    }

    func willAdd(slice: BudgetSlice) throws {
        try Self.willAdd(slice: slice, to: slices)
    }

    func willDelete(slicesWith identifiers: Set<BudgetSlice.ID>) throws {
        var updatedSlices = slices
        updatedSlices.removeAll(where: { identifiers.contains($0.id) })
        try Self.canUse(slices: updatedSlices)
    }

    static func willAdd(slice: BudgetSlice, to list: [BudgetSlice]) throws {
        guard !list.contains(where: { $0.name == slice.name }) else {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: slice.name))
        }
    }

    private static func canUse(name: String) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
    }

    private static func canUse(slices: [BudgetSlice]) throws {
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        guard !slices.containsDuplicates() else {
            throw DomainError.budget(error: .multipleSlicesWithSameName)
        }
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
        return self
            .enumerated()
            .filter { index, budget -> Bool in indices.contains(index) }
            .map(\.element)
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
