//
//  Transaction.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

enum Transaction: Identifiable, AmountHolder {
    case expense(TransactionContent)
    case income(TransactionContent)

    var id: UUID {
        return content.id
    }

    var amount: MoneyValue {
        return content.amount
    }

    var content: TransactionContent {
        switch self {
        case .expense(let transactionContent):
            return transactionContent
        case .income(let transactionContent):
            return transactionContent
        }
    }
}

struct TransactionContent: Identifiable, AmountHolder {

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
