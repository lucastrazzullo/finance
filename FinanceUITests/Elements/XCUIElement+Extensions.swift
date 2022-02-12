//
//  XCUIElement+Extensions.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

extension XCUIElement {

    func waitForEsistanceAndTap() {
        self.assertExists()
        self.tap()
    }

    func assertExists() {
        XCTAssert(self.waitForExistence(timeout: 1))
    }

    func assertDoesntExists() {
        XCTAssertFalse(self.waitForExistence(timeout: 1))
    }
}
