//
//  MonthlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import Foundation

struct MonthlyBudgetOverview: Hashable {

    let name: String
    let icon: Icon
    let startingAmount: MoneyValue
    let totalExpenses: MoneyValue

    var remainingAmount: MoneyValue {
        startingAmount - totalExpenses
    }

    var remainingAmountPercentage: Float {
        Float(truncating: NSDecimalNumber(decimal: 1 - totalExpenses.value / startingAmount.value))
    }
}
