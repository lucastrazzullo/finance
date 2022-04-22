//
//  DashboardViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol DashboardHandler: AnyObject {
    func load() async throws
}

@MainActor final class DashboardViewModel: ObservableObject {

    typealias Handler = DashboardHandler & BudgetHandler & BudgetsListHandler & OverviewListHandler

    var title: String {
        return yearlyOverview.name
    }

    var subtitle: String {
        return String(yearlyOverview.year)
    }

    var year: Int {
        return yearlyOverview.year
    }

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    var expenses: [Transaction] {
        return yearlyOverview.expenses
    }

    let yearlyOverview: YearlyBudgetOverview

    private(set) weak var handler: Handler?

    init(yearlyOverview: YearlyBudgetOverview, handler: Handler?) {
        self.yearlyOverview = yearlyOverview
        self.handler = handler
    }

    // MARK: Internal methods

    func load() async throws {
        try await handler?.load()
    }
}
