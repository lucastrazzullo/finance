//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    enum Error: Swift.Error {
        case sliceAlreadyExistsWith(name: String)
        case thereMustBeAtLeastOneSlice
    }

    let id: UUID
    let name: String
    private(set) var slices: [BudgetSlice]

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

    mutating func add(slice: BudgetSlice) throws {
        guard !slices.contains(where: { $0.name == slice.name }) else {
            throw Error.sliceAlreadyExistsWith(name: slice.name)
        }

        slices.append(slice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        guard slices.count > 1 else {
            throw Error.thereMustBeAtLeastOneSlice
        }

        slices.removeAll(where: { $0.id == slice.id })
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
