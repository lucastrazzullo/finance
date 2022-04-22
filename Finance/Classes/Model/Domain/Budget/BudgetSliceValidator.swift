//
//  BudgetSliceValidator.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import Foundation

enum BudgetSliceValidator {

    static func willAdd(schedule: BudgetSlice.Schedule, to list: [BudgetSlice.Schedule]) throws {
        guard !list.contains(where: { $0.month == schedule.month }) else {
            let monthName = Calendar.current.standaloneMonthSymbols[schedule.month - 1]
            throw DomainError.budgetSlice(error: .scheduleAlreadyExistsFor(month: monthName))
        }
    }
}
