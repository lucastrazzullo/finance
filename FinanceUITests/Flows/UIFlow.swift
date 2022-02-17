//
//  FinanceFlows.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

class UIFlow {

    let app: XCUIApplication
    let commonElements: CommonElements
    let parentFlow: UIFlow?

    init(app: XCUIApplication, parentFlow: UIFlow? = nil) {
        self.app = app
        self.commonElements = CommonElements(app: app)
        self.parentFlow = parentFlow
    }

    // MARK: Asserts

    func assertSomeErrorExists() -> Self {
        commonElements.someError.assertExists()
        return self
    }

    func assertSameNameErrorExists() -> Self {
        commonElements.sameNameError.assertExists()
        return self
    }

    func assertInvalidNameErrorExists() -> Self {
        commonElements.invalidNameError.assertExists()
        return self
    }

    func assertInvalidAmountErrorExists() -> Self {
        commonElements.invalidAmountError.assertExists()
        return self
    }
}
