//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {

    let id: UUID
    let name: String
    private(set) var slices: [BudgetSlice]

    var amount: MoneyValue {
        return slices.totalAmount
    }

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
        guard !name.isEmpty else {
            throw DomainError.budget(error: .nameNotValid)
        }
        guard !slices.isEmpty else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
        }
        if let duplicate = slices.firstDuplicate() {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: duplicate.name))
        }

        self.id = id
        self.name = name
        self.slices = slices
    }

    mutating func add(slice: BudgetSlice) throws {
        guard !slices.contains(where: { $0.name == slice.name }) else {
            throw DomainError.budget(error: .sliceAlreadyExistsWith(name: slice.name))
        }

        slices.append(slice)
    }

    mutating func remove(slice: BudgetSlice) throws {
        guard slices.count > 1 else {
            throw DomainError.budget(error: .thereMustBeAtLeastOneSlice)
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

        return try? Budget(id: identifier, name: name, slices: budgetSlices)
    }
}

