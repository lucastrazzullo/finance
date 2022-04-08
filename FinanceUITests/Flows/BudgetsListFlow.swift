//
//  BudgetsListFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 17/02/2022.
//

import XCTest

final class BudgetsListFlow<ParentFlow: UIFlow>: UIFlow {

    private let budgetsListElements: BudgetListViewElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.budgetsListElements = BudgetListViewElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Asserts

    func assertBudgetLinkDoesntExists() -> Self {
        budgetsListElements.budgetLink.assertDoesntExists()
        return self
    }

    func assertBudgetLinkExists() -> Self {
        budgetsListElements.budgetLink.assertExists()
        return self
    }

    // MARK: Actions

    func tapAddNewBudget() -> BudgetFlow<BudgetsListFlow> {
        budgetsListElements.addBudgetButton.waitForEsistanceAndTap()
        return BudgetFlow(app: app, parentFlow: self)
    }
}
