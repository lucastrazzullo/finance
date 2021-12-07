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
}
