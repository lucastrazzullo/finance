//
//  DashboardViewElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import XCTest

final class DashboardViewElements: FinanceElements {

    var budgetsTab: XCUIElement {
        tabBarQuery["Tab Bar"].buttons[AccessibilityIdentifier.DashboardView.budgetsTab]
    }
}
