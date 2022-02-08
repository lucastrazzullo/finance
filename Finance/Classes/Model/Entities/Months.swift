//
//  Months.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

struct Months {
    static let allMonths: [String] = {
        return Calendar.current.standaloneMonthSymbols
    }()

    static var currentMonthIdentifier: Int {
        return Calendar.current.component(.month, from: Date())
    }

    static func monthIdentifier(by index: Int) -> Int {
        return index + 1
    }

    static func monthIndex(for identifier: Int) -> Int {
        return identifier - 1
    }
}
