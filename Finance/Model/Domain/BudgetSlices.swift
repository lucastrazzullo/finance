//
//  BudgetSlices.swift
//  Finance
//
//  Created by Luca Strazzullo on 04/02/2022.
//

import Foundation

struct BudgetSlices: AmountHolder {

    private var list: [BudgetSlice]

    var amount: MoneyValue {
        return list.totalAmount
    }

    // MARK: Object life cycle

    init(list: [BudgetSlice]) throws {
        guard !list.isEmpty else {
            throw DomainError.budgetSlices(error: .thereMustBeAtLeastOneSlice)
        }
        self.list = list
    }

    // MARK: Getters

    func all() -> [BudgetSlice] {
        return list
    }

    func slice(with id: BudgetSlice.ID) -> BudgetSlice? {
        return list.first(where: { $0.id == id })
    }

    // MARK: Mutating methods

    mutating func add(newSlice: BudgetSlice) throws {
        if list.contains(where: { $0.name == newSlice.name }) {
            throw DomainError.budgetSlices(error: .sliceAlreadyExistsWith(name: newSlice.name))
        }
        list.append(newSlice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        guard list.contains(where: { $0.id == slice.id }) else {
            throw DomainError.budgetSlices(error: .sliceDoesntExist)
        }
        guard list.count > 1 else {
            throw DomainError.budgetSlices(error: .thereMustBeAtLeastOneSlice)
        }
        list.removeAll(where: { $0.id == slice.id })
    }
}
