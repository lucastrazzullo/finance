//
//  AddBudgetUITests.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 09/02/2022.
//

import XCTest
@testable import Finance

final class AddBudgetUITests: XCTestCase {

    private var app: XCUIApplication!
    private var flow: UIFlow!

    // MARK: Test life cycle

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        flow = nil
        app = nil
    }

    // MARK: Happy flows

    func testAddBudget() {
        flow = AddBudgetFlow(app: app)
            .start()
            .assertBudgetLinkDoesntExists()
            .addBudget()
            .assertBudgetLinkExists()
    }

    func testAddBudget_withSameName() {
        flow = AddBudgetFlow(app: app)
            .start()
            .assertBudgetLinkDoesntExists()
            .addBudget()
            .addBudget()
            .assertSameNameErrorExists()
    }

    func testAddBudget_withoutName() {
        flow = AddBudgetFlow(app: app)
            .start()
            .assertBudgetLinkDoesntExists()
            .addBudget(withName: false)
            .assertInvalidNameErrorExists()
    }

    func testAddBudget_withoutAmount() {
        flow = AddBudgetFlow(app: app)
            .start()
            .assertBudgetLinkDoesntExists()
            .addBudget(withAmount: false)
            .assertInvalidAmountErrorExists()
    }
}
