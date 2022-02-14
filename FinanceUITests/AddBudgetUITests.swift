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

    // MARK: - Happy cases

    func testAddBudgetWithAmount() {
        flow = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetAmount()
            .tapSave()

            .assertBudgetLinkExists()
    }

    func testAddBudgetWithSlices() {
        flow = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .tapSave()

            .assertBudgetLinkExists()
    }

    // MARK: - Unhappy cases

    func testAddBudget_withSameName() {
        flow = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetAmount()
            .tapSave()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetAmount()
            .tapSave()

            .assertSameNameErrorExists()
    }

    func testAddBudget_withoutName() {
        flow = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetAmount()
            .tapSave()

            .assertInvalidNameErrorExists()
    }

    func testAddBudget_withoutAmount() {
        flow = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .tapSave()

            .assertInvalidAmountErrorExists()
    }
}
