//
//  ReportFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 17/02/2022.
//

import XCTest

final class ReportFlow<ParentFlow: UIFlow>: UIFlow {

    private let reportElements: ReportElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.reportElements = ReportElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
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

    // MARK: Actions

    func tapAddNewBudget() -> BudgetFlow<ReportFlow> {
        reportElements.addBudgetButton.waitForEsistanceAndTap()
        return BudgetFlow(app: app, parentFlow: self)
    }
}
