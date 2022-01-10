//
//  DateFormatter+Defaults.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

extension DateFormatter {

    static let transactionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy hh:mm"
        return formatter
    }()
}
