//
//  FinanceFlows.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

protocol UIFlow {
    var app: XCUIApplication { get }
    var commonElements: CommonElements { get }
}

extension UIFlow {

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
