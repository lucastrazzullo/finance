//
//  Date+Extensions.swift
//  Finance
//
//  Created by Luca Strazzullo on 15/04/2022.
//

import Foundation

extension Date {

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    static func with(year: Int, month: Int? = nil, day: Int? = nil) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        return Calendar.current.date(from: components)
    }
}
