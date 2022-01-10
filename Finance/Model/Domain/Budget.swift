//
//  Budget.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Budget: Identifiable, AmountHolder {
    let id: UUID = UUID()
    let amount: MoneyValue
    let category: Category.ID
}
