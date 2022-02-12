//
//  AddBudgetFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 12/02/2022.
//

import XCTest

final class AddBudgetFlow: UIFlow {

    var commonElements: CommonElements

    private let reportElements: ReportElements
    private let newBudgetElements: NewBudgetElements

    init(app: XCUIApplication) {
        commonElements = CommonElements(app: app)
        reportElements = ReportElements(app: app)
        newBudgetElements = NewBudgetElements(app: app)
    }

    // MARK: Internal methods

    func addBudget(withName: Bool = true, withAmount: Bool = true) -> Self {
        var flow = tapAddNewBudget()

        if withName {
            flow = flow.insertNewBudgetName()
        }

        if withAmount {
            flow = flow.insertNewBudgetAmount()
        }

        return flow.tapSave()
    }

    func assertBudgetLinkDoesntExists() -> Self {
        reportElements.budgetLink.assertDoesntExists()
        return self
    }

    func assertBudgetLinkExists() -> Self {
        reportElements.budgetLink.assertExists()
        return self
    }

    // MARK: Private methods

    private func tapAddNewBudget() -> Self {
        reportElements.addBudgetButton.waitForEsistanceAndTap()
        return self
    }

    private func insertNewBudgetName() -> Self {
        newBudgetElements.nameTextField.waitForEsistanceAndTap()
        newBudgetElements.nameTextField.typeText("Test")
        return self
    }

    private func insertNewBudgetAmount() -> Self {
        newBudgetElements.amountTextField.waitForEsistanceAndTap()
        newBudgetElements.amountTextField.typeText("100")
        return self
    }

    private func tapSave() -> Self {
        newBudgetElements.saveButton.waitForEsistanceAndTap()
        return self
    }
}
