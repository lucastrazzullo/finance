//
//  Transaction.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Transaction: Identifiable, AmountHolder {

    let id: UUID = UUID()
    let date: Date = Date()
    let amount: MoneyValue
    let description: String?

    let category: Category.ID
    let subcategory: Subcategory.ID?

    init(amount: MoneyValue, description: String? = nil, category: Category.ID, subcategory: Subcategory.ID? = nil) {
        self.amount = amount
        self.description = description
        self.category = category
        self.subcategory = subcategory
    }
}
