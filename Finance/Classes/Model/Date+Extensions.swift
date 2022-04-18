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
}
