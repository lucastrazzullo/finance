//
//  Transaction.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import Foundation

struct Transaction: AmountHolder {

    let amount: MoneyValue
    let date: Date
    let budgetSliceId: BudgetSlice.ID

    var year: Int {
        return Calendar.current.component(.year, from: date)
    }

    var month: Int {
        return Calendar.current.component(.month, from: date)
    }
}
