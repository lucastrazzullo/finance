//
//  AddBudgetFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class AddBudgetFlow: UIFlow {

    let app: XCUIApplication
    let commonElements: CommonElements

    private let reportElements: ReportElements
    private let newBudgetElements: NewBudgetElements

    init(app: XCUIApplication) {
        self.app = app
        self.commonElements = CommonElements(app: app)
        self.reportElements = ReportElements(app: app)
        self.newBudgetElements = NewBudgetElements(app: app)
    }

    // MARK: Asserts

    func assertBudgetLinkDoesntExists() -> Self {
        reportElements.budgetLink.assertDoesntExists()
        return self
    }

    func assertBudgetLinkExists() -> Self {
        reportElements.budgetLink.assertExists()
        return self
    }

    func assertSliceItemDoesntExists() -> Self {
        newBudgetElements.sliceItem.assertDoesntExists()
        return self
    }

    func assertSliceItemExists() -> Self {
        newBudgetElements.sliceItem.assertExists()
        return self
    }

    // MARK: Actions

    func tapAddNewBudget() -> Self {
        reportElements.addBudgetButton.waitForEsistanceAndTap()
        return self
    }

    func tapAddNewSlice() -> AddSliceFlow {
        return AddSliceFlow(app: app)
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
        _ = AddSliceFlow(app: app)
            .tapAddNewSlice()
            .insertNewSliceName()
            .insertNewSliceAmount()
            .tapSave()

        return self
    }

    func tapSave() -> Self {
        newBudgetElements.saveButton.waitForEsistanceAndTap()
        return self
    }
}
