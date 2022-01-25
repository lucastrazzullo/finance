//
//  BudgetSlice.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct BudgetSlice: Identifiable, Hashable, AmountHolder {

    let id: UUID
    let name: String
    let amount: MoneyValue

    static let defaultName: String = "Default"

    // MARK: Object life cycle

    static func `default`(amount: MoneyValue) -> Self {
        try! BudgetSlice(id: .init(), name: defaultName, amount: amount)
    }

    init(id: UUID, name: String, amount: String) throws {
        guard let amount = MoneyValue.string(amount) else {
            throw DomainError.budgetSlice(error: .amountNotValid)
        }

        try self.init(id: id, name: name, amount: amount)
    }

    init(id: UUID, name: String, amount: MoneyValue) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetSlice(error: .nameNotValid)
        }

        self.id = id
        self.name = name
        self.amount = amount
    }

    // MARK: Hashable conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount.value)
    }
}

extension BudgetSlice {

    static func with(budgetSliceEntity: BudgetSliceEntity) -> Self? {
        guard let identifier = budgetSliceEntity.identifier,
              let name = budgetSliceEntity.name,
              let amountDecimal = budgetSliceEntity.amount else {
            return nil
        }

        return try? BudgetSlice(id: identifier, name: name, amount: .value(amountDecimal.decimalValue))
    }
}

extension Array where Element == BudgetSlice {

    func firstDuplicate() -> Element? {
        var firstDuplicate: Element? = nil
        var uniqueNames: Set<String> = []

        self.forEach { budgetSlice in
            guard firstDuplicate == nil else {
                return
            }
            if uniqueNames.contains(budgetSlice.name) {
                firstDuplicate = budgetSlice
            } else {
                uniqueNames.insert(budgetSlice.name)
            }
        }

        return firstDuplicate
    }
}
