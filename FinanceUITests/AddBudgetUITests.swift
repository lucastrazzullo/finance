//
//  AddBudgetUITests.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 09/02/2022.
//

import XCTest
@testable import Finance

final class AddBudgetUITests: FinanceUITestCase {

    // MARK: - Happy cases

    func testAddBudgetWithAmount() {
        _ = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetAmount()
            .tapSave()

            .assertBudgetLinkExists()
    }

    func testAddBudgetWithSlices() {
        _ = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .tapSave()

            .assertBudgetLinkExists()
    }

    // MARK: - Unhappy cases

    func testAddBudget_withSameName() {
        _ = AddBudgetFlow(app: app)
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

    func testAddBudget_withSameSlice() {
        _ = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .insertNewBudgetSlice()

            .assertSameNameErrorExists()
    }

    func testAddBudget_withoutName() {
        _ = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetAmount()
            .tapSave()

            .assertInvalidNameErrorExists()
    }

    func testAddBudget_withoutAmount() {
        _ = AddBudgetFlow(app: app)
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .tapSave()

            .assertInvalidAmountErrorExists()
    }
}
