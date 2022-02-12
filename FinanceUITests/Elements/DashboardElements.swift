//
//  DashboardElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class DashboardElements: FinanceElements {

    var budgetsLink: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.DashboardView.budgetsLink]
    }
}
