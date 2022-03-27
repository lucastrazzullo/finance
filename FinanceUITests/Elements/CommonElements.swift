//
//  CommonElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class CommonElements: FinanceElements {

    var someError: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.Error.someError]
    }

    var sameNameError: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.Error.sameNameError]
    }

    var invalidNameError: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.Error.invalidNameError]
    }

    var invalidAmountError: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.Error.invalidAmountError]
    }

    var invalidSlicesError: XCUIElement {
        tablesQuery.staticTexts[AccessibilityIdentifier.Error.invalidSlicesError]
    }
}
