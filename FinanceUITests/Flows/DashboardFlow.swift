//
//  DashboardFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import XCTest

final class DashboardFlow<ParentFlow: UIFlow>: UIFlow {

    private let dashboardElements: DashboardViewElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.dashboardElements = DashboardViewElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Actions

    func tapBudgetsTab() -> BudgetsListFlow<DashboardFlow> {
        dashboardElements.budgetsTab.waitForEsistanceAndTap()
        return BudgetsListFlow(app: app, parentFlow: self)
    }
}
