//
//  Mocks.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import Foundation

#if DEBUG
enum Mocks {

    // MARK: - Categories

    static let categories: [Category] = {
        [
            Category(name: "EMA"),
            Category(name: "ING"),
            Category(name: "House"),
            Category(name: "Groceries"),
            Category(name: "Health")
        ]
    }()

    static let subcategories: [Subcategory] = {
        [
            Subcategory(name: "Mortgage", category: categories[2].id),
            Subcategory(name: "Furnitures", category: categories[2].id)
        ]
    }()

    private static let incomingCategories: [Category] = { categories[0...1].compactMap({$0}) }()
    private static let outgoingCategories: [Category] = { categories[2...4].compactMap({$0}) }()

    // MARK: - Budgets

    static let incomingBudgetList: [Budget] = {
        incomingCategories.map { category in
            Budget(amount: .value(200.01), category: category.id)
        }
    }()

    static let outgoingBudgetList: [Budget] = {
        outgoingCategories.map { category in
            Budget(amount: .value(200.01), category: category.id)
        }
    }()

    // MARK: - Transactions

    static let incomingTransactions: [Transaction] = {
        incomingCategories
            .map { category in
                [
                    Transaction(amount: .value(100.02), category: category.id),
                    Transaction(amount: .value(200.02), category: category.id),
                    Transaction(amount: .value(300.02), category: category.id)
                ]
            }
            .flatMap({$0})
    }()

    static let outgoingTransactions: [Transaction] = {
        outgoingCategories
            .map { category in
                [
                    Transaction(amount: .value(100.02), category: category.id),
                    Transaction(amount: .value(200.02), category: category.id),
                    Transaction(amount: .value(300.02), category: category.id)
                ]
            }
            .flatMap({$0})
    }()
}
#endif
