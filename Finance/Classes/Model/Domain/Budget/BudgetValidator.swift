//
//  BudgetValidator.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import Foundation

enum BudgetValidator {

    static func willAdd(slice: BudgetSlice, to list: [BudgetSlice]) throws {
        guard !list.contains(where: { $0.name == slice.name }) else {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: slice.name))
        }
    }

    static func willDelete(slicesWith identifiers: Set<BudgetSlice.ID>, from list: [BudgetSlice]) throws {
        var list = list
        list.removeAll(where: { identifiers.contains($0.id) })
        try canUse(slices: list)
    }

    static func canUse(name: String) throws {
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
    }

    static func canUse(slices: [BudgetSlice]) throws {
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        guard !slices.containsDuplicates() else {
            throw DomainError.budget(error: .multipleSlicesWithSameName)
        }
    }
}
