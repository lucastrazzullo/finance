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

    func testAddSliceToNewBudget() {
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
}
