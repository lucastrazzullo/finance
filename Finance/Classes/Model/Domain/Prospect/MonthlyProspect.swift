//
//  MonthlyProspect.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/05/2022.
//

import Foundation

struct MonthlyProspect: Identifiable {

    enum State {
        case closed(forecastedAmount: MoneyValue, closingAmount: MoneyValue)
        case current(forecastedAmount: MoneyValue, actualAmount: MoneyValue)
        case future(forecastedAmount: MoneyValue, trendingAmount: MoneyValue)
    }

    var id: Int {
        return month
    }

    let month: Int
    let state: State

    // MARK: Object life cycle

    init(year: Int, month: Int, openingYearBalance: MoneyValue, transactions: [Transaction], budgets: [Budget]) {
        self.month = month

//        let budgetAvailabilityUntilMonth = budgets.availability(upTo: month)
//        let budgetAvailabilityInMonth = budgets.availability(for: month)

//        let incomes = transactions.filter({ $0.budgetKind == .income })
//        let expenses = transactions.filter({ $0.budgetKind == .expense })

        let balanceToDate = MoneyValue.zero
        let forecastedAmount = MoneyValue.zero
        let trendingAmount = MoneyValue.zero

        let currentMonth = Calendar.current.component(.month, from: .now)
        if month < currentMonth {
            self.state = .closed(forecastedAmount: forecastedAmount, closingAmount: balanceToDate)
        } else if month > currentMonth {
            self.state = .future(forecastedAmount: forecastedAmount, trendingAmount: trendingAmount)
        } else {
            self.state = .current(forecastedAmount: forecastedAmount, actualAmount: balanceToDate)
        }
    }
}
