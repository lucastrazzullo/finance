//
//  SliceFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 14/02/2022.
//

import XCTest

final class SliceFlow<ParentFlow: UIFlow>: UIFlow {

    private let newBudgetElements: NewBudgetElements
    private let newSliceElements: NewSliceElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.newBudgetElements = NewBudgetElements(app: app)
        self.newSliceElements = NewSliceElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Actions

    func tapAddNewSlice() -> Self {
        newBudgetElements.addSliceButton.waitForEsistanceAndTap()
        return self
    }

    func insertNewSliceName() -> Self {
        newSliceElements.nameTextField.waitForEsistanceAndTap()
        newSliceElements.nameTextField.typeText("Test")
        return self
    }

    func insertNewSliceAmount() -> Self {
        newSliceElements.amountTextField.waitForEsistanceAndTap()
        newSliceElements.amountTextField.typeText("100")
        return self
    }

    func tapSave() -> ParentFlow? {
        newSliceElements.saveButton.waitForEsistanceAndTap()
        return parentFlow as? ParentFlow
    }
}
