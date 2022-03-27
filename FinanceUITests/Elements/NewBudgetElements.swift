//
//  NewBudgetElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class NewBudgetElements: FinanceElements {

    var nameTextField: XCUIElement {
        tablesQuery.textFields[AccessibilityIdentifier.NewBudgetView.nameInputField]
    }

    var sliceItem: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.NewBudgetView.sliceItem]
    }

    var addSliceButton: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.NewBudgetView.addSliceButton]
    }

    var saveButton: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.NewBudgetView.saveButton]
    }
}
