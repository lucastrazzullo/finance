//
//  Transaction.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import Foundation

struct Transaction: Hashable, AmountHolder, Identifiable {

    let id: UUID = .init()
    let description: String?
    let amount: MoneyValue
    let date: Date
    let budgetSliceId: BudgetSlice.ID

    var year: Int {
        return Calendar.current.component(.year, from: date)
    }

    var month: Int {
        return Calendar.current.component(.month, from: date)
    }
}

extension Array where Element == Transaction {

    func with(identifier: Budget.ID) -> Transaction? {
        return self.first(where: { $0.id == identifier })
    }
}
