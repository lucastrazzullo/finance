//
//  AccessibilityIdentifier.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/02/2022.
//

import Foundation

enum AccessibilityIdentifier {

    enum Error {
        static let someError = "SomeError"

        static let sameNameError = "SameNameError"
        static let invalidNameError = "InvalidNameError"
        static let invalidAmountError = "InvalidAmountError"
    }

    enum DashboardView {
        static let budgetsLink = "BudgetsLink"
    }

    enum ReportView {
        static let addBudgetButton = "AddBudgetButton"
        static let budgetLink = "BudgetLink"
    }

    enum NewBudgetView {
        static let nameInputField = "BudgetNameInputField"
        static let amountInputField = "BudgetAmountInputField"
        static let saveButton = "SaveBudgetButton"
    }
}
