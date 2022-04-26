//
//  YearlyOverviewFlow.swift
//  FinanceUITests
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import XCTest

final class YearlyOverviewFlow<ParentFlow: UIFlow>: UIFlow {

    private let dashboardElements: YearlyOverviewViewElements

    init(app: XCUIApplication, parentFlow: ParentFlow? = nil) {
        self.dashboardElements = YearlyOverviewViewElements(app: app)
        super.init(app: app, parentFlow: parentFlow)
    }

    // MARK: Actions

    func tapBudgetsTab() -> BudgetsListFlow<YearlyOverviewFlow> {
        dashboardElements.budgetsTab.waitForEsistanceAndTap()
        return BudgetsListFlow(app: app, parentFlow: self)
    }
}
