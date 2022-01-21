//
//  TransferHolder.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

protocol TransferHolder {
    var transfer: Transfer { get }
}

extension Sequence where Element: TransferHolder {

    var totalAmount: MoneyValue {
        reduce(.zero, { totalAmount, element in
            switch element.transfer {
            case .expense(let amount):
                return totalAmount - amount
            case .income(let amount):
                return totalAmount + amount
            }
        })
    }
}
