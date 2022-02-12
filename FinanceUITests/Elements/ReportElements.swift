//
//  ReportElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class ReportElements: FinanceElements {

    var budgetLink: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.ReportView.budgetLink]
    }

    var addBudgetButton: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.ReportView.addBudgetButton]
    }
}
