//
//  Transfer.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

enum Transfer: AmountHolder {
    case expense(amount: MoneyValue)
    case income(amount: MoneyValue)

    var amount: MoneyValue {
        switch self {
        case .expense(let amount):
            return amount
        case .income(let amount):
            return amount
        }
    }
}
