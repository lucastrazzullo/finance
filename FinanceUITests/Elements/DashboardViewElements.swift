//
//  YearlyOverviewViewElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import XCTest

final class YearlyOverviewViewElements: FinanceElements {

    var budgetsTab: XCUIElement {
        tabBarQuery["Tab Bar"].buttons[AccessibilityIdentifier.YearlyOverviewView.budgetsTab]
    }
}
