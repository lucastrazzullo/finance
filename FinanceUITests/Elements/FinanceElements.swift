//
//  FinanceElements.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

class FinanceElements {

    private let app: XCUIApplication

    lazy var tabBarQuery: XCUIElementQuery = app.tabBars
    lazy var tablesQuery: XCUIElementQuery = app.tables

    init(app: XCUIApplication) {
        self.app = app
    }
}
