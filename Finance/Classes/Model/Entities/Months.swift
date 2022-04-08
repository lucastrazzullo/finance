//
//  Months.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

struct Months {

    static let `default` = Months(calendar: Calendar.current)

    private let calendar: Calendar

    // MARK: Object life cycle

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    // MARK: Computed properties

    var all: [Month] {
        return calendar.standaloneMonthSymbols.map { Month(id: $0, name: $0) }
    }

    var current: Month {
        let identifier = calendar.component(.month, from: Date())
        return all[monthIndex(for: identifier)]
    }

    // MARK: Subscripts

    subscript(atIndex: Int) -> Month? {
        guard all.indices.contains(atIndex) else {
            return nil
        }
        return all[atIndex]
    }

    subscript(withIdentifier: Month.ID) -> Month? {
        return all.first(where: { $0.id == withIdentifier })
    }

    // MARK: Private helper methods

    private func monthIdentifier(by index: Int) -> Int {
        return index + 1
    }

    private func monthIndex(for identifier: Int) -> Int {
        return identifier - 1
    }
}

struct Month: Identifiable, Equatable {

    typealias ID = String

    let id: ID
    let name: String

    fileprivate init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
