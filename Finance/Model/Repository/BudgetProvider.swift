//
//  BudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

final class BudgetProvider {

    static let incomingBudgetList: [Budget] = {
        [
            Budget(name: "EMA", amount: .value(200.01)),
            Budget(name: "ING", amount: .value(200.01)),
        ]
    }()

    static let expensesBudgetList: [Budget] = {
        [
            Budget(name: "House", slices: [
                .init(name: "Mortgage", amount: .value(120.23)),
                .init(name: "Furnitures", amount: .value(120.23))
            ]),
            Budget(name: "Groceries", amount: .value(200.01)),
            Budget(name: "Health", amount: .value(200.01))
        ]
    }()
}
