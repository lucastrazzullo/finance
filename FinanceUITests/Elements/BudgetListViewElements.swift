//
//  BudgetListViewElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class BudgetListViewElements: FinanceElements {

    var budgetLink: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.BudgetsListView.budgetLink]
    }

    var addBudgetButton: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.BudgetsListView.addBudgetButton]
    }
}
