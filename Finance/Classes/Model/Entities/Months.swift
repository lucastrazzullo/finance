//
//  Months.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

struct Months {

    static let `default` = Months(all: Calendar.current.standaloneMonthSymbols.map { Month(id: $0, name: $0) })

    let all: [Month]

    subscript(atIndex: Int) -> Month? {
        guard all.indices.contains(atIndex) else {
            return nil
        }
        return all[atIndex]
    }

    subscript(withIdentifier: Month.ID) -> Month? {
        return all.first(where: { $0.id == withIdentifier })
    }

    private func monthIdentifier(by index: Int) -> Int {
        return index + 1
    }

    private func monthIndex(for identifier: Int) -> Int {
        return identifier - 1
    }
}

struct Month: Identifiable, Equatable {

    let id: String
    let name: String

    fileprivate init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
