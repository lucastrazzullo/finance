//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable {
    let id: UUID = UUID()
    let name: String
    let baskets: [Basket]

    var totalAmount: MoneyValue {
        return baskets.totalAmount
    }
}
