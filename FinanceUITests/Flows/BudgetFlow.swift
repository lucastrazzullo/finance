//
//  BudgetFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class BudgetFlow<ParentFlow: UIFlow>: UIFlow {

    private let reportElements: ReportElements
    private let newBudgetElements: NewBudgetElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.reportElements = ReportElements(app: app)
        self.newBudgetElements = NewBudgetElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Asserts

    func assertSliceItemDoesntExists() -> Self {
        newBudgetElements.sliceItem.assertDoesntExists()
        return self
    }

    func assertSliceItemExists() -> Self {
        newBudgetElements.sliceItem.assertExists()
        return self
    }

    // MARK: Actions

    func tapAddNewSlice() -> SliceFlow<BudgetFlow> {
        return SliceFlow(app: app, parentFlow: self)
            .tapAddNewSlice()
    }

    func insertNewBudgetName() -> Self {
        newBudgetElements.nameTextField.waitForEsistanceAndTap()
        newBudgetElements.nameTextField.typeText("Test")
        return self
    }

    func insertNewBudgetAmount() -> Self {
        newBudgetElements.amountTextField.waitForEsistanceAndTap()
        newBudgetElements.amountTextField.typeText("100")
        return self
    }

    func insertNewBudgetSlice() -> Self {
        _ = SliceFlow(app: app, parentFlow: self)
            .tapAddNewSlice()
            .insertNewSliceName()
            .insertNewSliceAmount()
            .tapSave()

        return self
    }

    func tapSave() -> ParentFlow? {
        newBudgetElements.saveButton.waitForEsistanceAndTap()
        return parentFlow as? ParentFlow
    }
}
