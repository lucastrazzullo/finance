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

    func testAddBudgetWithSlices() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .tapSave()?

            .assertBudgetLinkExists()
    }

    // MARK: - Unhappy cases

    func testAddBudget_withSameName() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .tapSave()?

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .tapSave()?

            .assertSameNameErrorExists()
    }

    func testAddBudget_withSameSlice() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .insertNewBudgetSlice()
            .insertNewBudgetSlice()

            .assertSameNameErrorExists()
    }

    func testAddBudget_withoutName() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetSlice()
            .tapSave()?

            .assertInvalidNameErrorExists()
    }

    func testAddBudget_withoutSlices() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .assertBudgetLinkDoesntExists()

            .tapAddNewBudget()
            .insertNewBudgetName()
            .tapSave()?

            .assertInvalidSlicesErrorExists()
    }
}
