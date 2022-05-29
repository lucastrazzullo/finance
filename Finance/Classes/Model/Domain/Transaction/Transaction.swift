//
//  Transaction.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import Foundation

struct Transaction: Hashable, AmountHolder, Identifiable {

    struct Amount: Hashable {
        let amount: MoneyValue
        let budgetKind: Budget.Kind
        let budgetIdentifier: Budget.ID
        let sliceIdentifier: BudgetSlice.ID
    }

    let id: UUID
    let description: String?
    let date: Date
    let amounts: [Amount]

    var amount: MoneyValue {
        return amounts.balance
    }

    var budgetKind: Budget.Kind {
        return amounts[0].budgetKind
    }

    init(id: UUID, description: String?, date: Date, amounts: [Amount]) throws {
        guard !amounts.isEmpty else {
            throw DomainError.transaction(error: .amountNotValid)
        }
        guard !amounts.map(\.budgetKind).containsMultipleKinds() else {
            throw DomainError.transaction(error: .amountsMustBeOfSameKind)
        }

        self.id = id
        self.description = description
        self.date = date
        self.amounts = amounts
    }
}

extension Array where Element == Transaction {

    func totalAmount(upTo month: Int) -> MoneyValue {
        return self.filter({ $0.date.month < month }).totalAmount
    }

    func totalAmount(in month: Int) -> MoneyValue {
        return self.filter({ $0.date.month == month }).totalAmount
    }
}

extension Array where Element == Transaction {

    // MARK: Look-up

    func with(identifier: Transaction.ID) -> Transaction? {
        return self.first(where: { $0.id == identifier })
    }

    func at(offsets: IndexSet) -> [Transaction] {
        return NSArray(array: self).objects(at: offsets) as? [Transaction] ?? []
    }

    // MARK: Delete

    mutating func delete(withIdentifiers identifiers: Set<Transaction.ID>) {
        self.removeAll(where: { identifiers.contains($0.id) })
    }
}

extension Array where Element == Transaction.Amount {

    var balance: MoneyValue {
        reduce(.zero, {
            switch $1.budgetKind {
            case .expense:
                return $0 - $1.amount
            case .income:
                return $0 + $1.amount
            }
        })
    }

}
