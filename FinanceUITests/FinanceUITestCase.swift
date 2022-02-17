//
//  FinanceUITestCase.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 14/02/2022.
//

import Foundation
import XCTest

class FinanceUITestCase: XCTestCase {

    var app: XCUIApplication!

    // MARK: Test life cycle

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
}
