//
//  FinanceFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import XCTest

final class FinanceFlow<ParentFlow: UIFlow>: UIFlow {

    private let dashboardElements: FinanceViewElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.dashboardElements = FinanceViewElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Actions

    func tapBudgetsTab() -> BudgetsListFlow<FinanceFlow> {
        dashboardElements.budgetsTab.waitForEsistanceAndTap()
        return BudgetsListFlow(app: app, parentFlow: self)
    }
}
