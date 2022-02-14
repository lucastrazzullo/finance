//
//  AddSliceFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 14/02/2022.
//

import XCTest

final class AddSliceFlow: UIFlow {

    let app: XCUIApplication
    let commonElements: CommonElements

    private let newBudgetElements: NewBudgetElements
    private let newSliceElements: NewSliceElements

    init(app: XCUIApplication) {
        self.app = app
        self.commonElements = CommonElements(app: app)
        self.newBudgetElements = NewBudgetElements(app: app)
        self.newSliceElements = NewSliceElements(app: app)
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

    func tapSave() -> Self {
        newSliceElements.saveButton.waitForEsistanceAndTap()
        return self
    }
}
