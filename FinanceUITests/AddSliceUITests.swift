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
        let addBudgetFlow = AddBudgetFlow(app: app)
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
        _ = AddBudgetFlow(app: app)
            .tapAddNewBudget()
            .insertNewBudgetSlice()

            .tapAddNewSlice()
            .insertNewSliceName()
            .insertNewSliceAmount()
            .tapSave()

            .assertSameNameErrorExists()
    }

    func testAddSlice_toNewBudget_withoutName() {
        _ = AddBudgetFlow(app: app)
            .tapAddNewBudget()
            .tapAddNewSlice()
            .insertNewSliceAmount()
            .tapSave()

            .assertInvalidNameErrorExists()
    }

    func testAddSlice_toNewBudget_withoutAmount() {
        _ = AddBudgetFlow(app: app)
            .tapAddNewBudget()
            .tapAddNewSlice()
            .insertNewSliceName()
            .tapSave()

            .assertInvalidAmountErrorExists()
    }
}
