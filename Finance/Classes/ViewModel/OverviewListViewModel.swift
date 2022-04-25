//
//  OverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol OverviewListViewDelegate: AnyObject {
    func willAdd(expenses: [Transaction]) throws
    func didAdd(expenses: [Transaction]) throws
}

@MainActor final class OverviewListViewModel: ObservableObject {

    typealias Delegate = OverviewListViewDelegate & BudgetViewModelDelegate & TransactionsListViewModelDelegate

    @Published var yearlyOverview: YearlyBudgetOverview
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

    let month: Int

    private let storageProvider: StorageProvider
    private weak var delegate: Delegate?

    // MARK: Object life cycle

    init(month: Int, yearlyOverview: YearlyBudgetOverview, storageProvider: StorageProvider, delegate: Delegate?) {
        self.month = month
        self.yearlyOverview = yearlyOverview
        self.storageProvider = storageProvider
        self.delegate = delegate
    }

    // MARK: Internal methods

    func add(expenses: [Transaction]) async throws {
        try delegate?.willAdd(expenses: expenses)

        for expense in expenses {
            try await storageProvider.add(transaction: expense)
        }

        try yearlyOverview.append(expenses: expenses)
        try delegate?.didAdd(expenses: expenses)

        addNewTransactionIsPresented = false
    }
}
