//
//  AddSliceUITests.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 14/02/2022.
//

import Foundation
import XCTest

final class AddSliceUITests: FinanceUITestCase {

    // MARK: - Happy cases

    func testAddSlice_toNewBudget() {
        let addBudgetFlow = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .tapAddNewBudget()
            .assertSliceItemDoesntExists()

        _ = addBudgetFlow
            .tapAddNewSlice()
            .insertNewSliceName()
            .insertNewSliceAmount()
            .tapSave()

        _ = addBudgetFlow
            .assertSliceItemExists()
    }

    // MARK: - Unhappy cases

    func testAddSlice_toNewBudget_withSameName() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .tapAddNewBudget()
            .insertNewBudgetSlice()

            .tapAddNewSlice()
            .insertNewSliceName()
            .insertNewSliceAmount()
            .tapSave()?

            .assertSameNameErrorExists()
    }

    func testAddSlice_toNewBudget_withoutName() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .tapAddNewBudget()
            .tapAddNewSlice()
            .insertNewSliceAmount()
            .tapSave()?

            .assertInvalidNameErrorExists()
    }

    func testAddSlice_toNewBudget_withoutAmount() {
        _ = YearlyOverviewFlow(app: app)
            .tapBudgetsTab()
            .tapAddNewBudget()
            .tapAddNewSlice()
            .insertNewSliceName()
            .tapSave()?

            .assertInvalidAmountErrorExists()
    }
}
