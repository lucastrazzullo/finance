//
//  MonthlyOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/05/2022.
//

import Foundation

struct MonthlyOverview: Identifiable {

    enum Balance {
        case closed(closingAmount: MoneyValue)
        case current(actualAmount: MoneyValue)
        case future(trendingAmount: MoneyValue)
    }

    var id: Int {
        return month
    }

    let month: Int
    let openingBalance: MoneyValue
    let forecastedEndOfMonthBalance: MoneyValue
    let effectiveBalance: Balance

    private(set) var budgets: [Budget]
    private(set) var transactions: [Transaction]

    // MARK: Object life cycle

    init(month: Int, openingBalance: MoneyValue, transactions: [Transaction], budgets: [Budget]) {
        self.budgets = budgets
        self.transactions = transactions.filter({ $0.date.month == month })

        self.month = month
        self.openingBalance = openingBalance
        self.forecastedEndOfMonthBalance = openingBalance + budgets.availability(for: month)

        let currentMonth = Calendar.current.component(.month, from: .now)
        if month < currentMonth {
            let balanceToDate = openingBalance + transactions.totalAmount(in: month)
            self.effectiveBalance = .closed(closingAmount: balanceToDate)
        } else if month > currentMonth {
            let trendingAmount = MoneyValue.zero
            self.effectiveBalance = .future(trendingAmount: trendingAmount)
        } else {
            let balanceToDate = openingBalance + transactions.totalAmount(in: month)
            self.effectiveBalance = .current(actualAmount: balanceToDate)
        }
    }
}
