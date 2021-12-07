//
//  Mocks.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import Foundation

#if DEBUG
enum Mocks {

    static var incomingBudgetList: [Budget] {
        return [
            Budget(name: "EMA", baskets: baskets),
            Budget(name: "ING", baskets: baskets)
        ]
    }

    static var expensesBudgetList: [Budget] {
        return [
            Budget(name: "Rent", baskets: baskets)
        ]
    }

    static var baskets: [Basket] {
        return [
            Basket(description: "January", amount: .value(1000.12)),
            Basket(description: "February", amount: .value(1000.12)),
            Basket(description: "March", amount: .value(1000.12))
        ]
    }

    static var transactions: [Transaction] {
        return [
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02)),
            Transaction(amount: .value(200.02))
        ]
    }
}
#endif
