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
    private(set) var name: String
    private(set) var slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

    // MARK: Object life cycle

    init(id: ID = .init(), name: String, monthlyAmount: MoneyValue = .zero) throws {
        let slices = [
            try BudgetSlice(id: .init(), name: Self.defaultSliceName, configuration: .montly(amount: monthlyAmount))
        ]
        try self.init(id: id, name: name, slices: slices)
    }

    init(id: ID = .init(), name: String, slices: [BudgetSlice]) throws {
        try Self.canUse(name: name)
        try Self.canUse(slices: slices)

        self.id = id
        self.name = name
        self.slices = slices
    }

    // MARK: Mutating methods

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

    /// Updates name in budget
    /// Parameters:
    ///     - name: New name of the budget
    ///
    mutating func update(name: String) throws {
        try willUpdate(name: name)
        self.name = name
    }

    // MARK: Getters

    func sliceIdentifiers(at indices: IndexSet) -> Set<BudgetSlice.ID> {
        return Set(slices(at: indices).map(\.id))
    }

    func slices(at indices: IndexSet) -> [BudgetSlice] {
        return slices
            .enumerated()
            .filter({ index, slice in indices.contains(index) })
            .map(\.element)
    }

    // MARK: Helpers

    func willAdd(slice: BudgetSlice) throws {
        try Self.willAdd(slice: slice, to: slices)
    }

    func willDelete(slicesWith identifiers: Set<BudgetSlice.ID>) throws {
        var updatedSlices = slices
        updatedSlices.removeAll(where: { identifiers.contains($0.id) })
        try Self.canUse(slices: updatedSlices)
    }

    func willUpdate(name: String) throws {
        try Self.canUse(name: name)
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
