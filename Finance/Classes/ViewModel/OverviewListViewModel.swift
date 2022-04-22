//
//  OverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol OverviewListHandler: AnyObject {
    func add(expenses: [Transaction]) async throws
}

@MainActor final class OverviewListViewModel: ObservableObject {

    @Published var month: Int = Calendar.current.component(.month, from: .now)
    @Published var addNewTransactionIsPresented: Bool = false

    var monthlyOverviews: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviews(month: month)
    }

    var monthlyOverviewsWithLowestAvailability: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month)
    }

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    let yearlyOverview: YearlyBudgetOverview

    private weak var handler: OverviewListHandler?

    // MARK: Object life cycle

    init(yearlyOverview: YearlyBudgetOverview, handler: OverviewListHandler?) {
        self.yearlyOverview = yearlyOverview
        self.handler = handler
    }

    // MARK: Internal methods

    func add(expenses: [Transaction]) async throws {
        try await handler?.add(expenses: expenses)
        addNewTransactionIsPresented = false
    }
}
