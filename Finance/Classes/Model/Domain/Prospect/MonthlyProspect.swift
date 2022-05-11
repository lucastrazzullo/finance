//
//  MonthlyProspect.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/05/2022.
//

import Foundation

struct MonthlyProspect: Hashable {

    let month: Int
    let forecastedEndOfTheMonthAvailability: MoneyValue
    let currentAvailability: MoneyValue

    init(month: Int, incomes: [Transaction], expenses: [Transaction], budgets: [Budget]) {
        self.month = month
        self.forecastedEndOfTheMonthAvailability = budgets
            .reduce(.zero, { $0 + $1.availability(upTo: month) + $1.availability(for: month) })
        self.currentAvailability = incomes
            .filter({ $0.month <= month })
            .totalAmount - expenses
            .filter({ $0.month <= month }).totalAmount
    }
}
