//
//  OverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol OverviewListViewDelegate: AnyObject {
    func willAdd(expenses: [Transaction]) throws
    func didAdd(expenses: [Transaction])
}

@MainActor final class OverviewListViewModel: ObservableObject {

    typealias Delegate = OverviewListViewDelegate & BudgetViewModelDelegate

    @Published var month: Int = Calendar.current.component(.month, from: .now)
    @Published var addNewTransactionIsPresented: Bool = false

    @Published var yearlyOverview: YearlyBudgetOverview

    weak var delegate: Delegate?

    var monthlyOverviews: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviews(month: month)
    }

    var monthlyOverviewsWithLowestAvailability: [MonthlyBudgetOverview] {
        return yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month)
    }

    var budgets: [Budget] {
        return yearlyOverview.budgets
    }

    private let storageProvider: StorageProvider

    // MARK: Object life cycle

    init(yearlyOverview: YearlyBudgetOverview, storageProvider: StorageProvider, delegate: Delegate?) {
        self.yearlyOverview = yearlyOverview
        self.storageProvider = storageProvider
        self.delegate = delegate
    }

    // MARK: Internal methods

    func add(expenses: [Transaction]) async throws {
        try delegate?.willAdd(expenses: expenses)

        for expense in expenses {
            try await storageProvider.add(transaction: expense)
            yearlyOverview.expenses.append(expense)
        }

        delegate?.didAdd(expenses: expenses)

        addNewTransactionIsPresented = false
    }
}
