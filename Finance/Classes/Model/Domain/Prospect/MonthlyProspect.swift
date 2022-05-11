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
    let trendingEndOfTheMonthAvailability: MoneyValue
    let currentAvailability: MoneyValue

    init(month: Int) {
        self.month = month
        self.forecastedEndOfTheMonthAvailability = .value(.init(Double.random(in: 10000...14000)))
        self.trendingEndOfTheMonthAvailability = forecastedEndOfTheMonthAvailability - .value(1000)
        self.currentAvailability = .value(.init(Double.random(in: 10000...14000)))
    }
}
