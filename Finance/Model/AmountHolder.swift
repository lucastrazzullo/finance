//
//  AmountHolder.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

protocol AmountHolder {
    var amount: MoneyValue { get }
}

extension Sequence where Element: AmountHolder {

    var totalAmount: MoneyValue {
        reduce(.zero, { $0 + $1.amount })
    }
}
