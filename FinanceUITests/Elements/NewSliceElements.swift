//
//  NewSliceElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 14/02/2022.
//

import XCTest

final class NewSliceElements: FinanceElements {

    var nameTextField: XCUIElement {
        tablesQuery.textFields[AccessibilityIdentifier.NewSliceView.nameInputField]
    }

    var amountTextField: XCUIElement {
        tablesQuery.textFields[AccessibilityIdentifier.NewSliceView.amountInputField]
    }

    var saveButton: XCUIElement {
        tablesQuery.buttons[AccessibilityIdentifier.NewSliceView.saveButton]
    }
}
