//
//  Basket.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Basket: Identifiable, AmountHolder {
    let id: UUID = UUID()
    let description: String
    let amount: MoneyValue
}
