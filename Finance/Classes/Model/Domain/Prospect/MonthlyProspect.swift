//
//  MonthlyProspect.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/05/2022.
//

import Foundation

struct MonthlyProspect: Hashable, Identifiable {

    var id: Int {
        return month
    }

    let month: Int
    let forecastedEndOfTheMonthAvailability: MoneyValue
    let trendingEndOfTheMonthAvailability: MoneyValue
    let currentAvailability: MoneyValue

    init(month: Int) {
        self.month = month
        self.forecastedEndOfTheMonthAvailability = .value(12000)
        self.trendingEndOfTheMonthAvailability = forecastedEndOfTheMonthAvailability - .value(1000)
        self.currentAvailability = .value(10000)
    }
}
