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

    private let storageProvider: StorageProvider
    private weak var delegate: Delegate?

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
        }

        try yearlyOverview.append(expenses: expenses)
        try delegate?.didAdd(expenses: expenses)

        addNewTransactionIsPresented = false
    }
}

extension OverviewListViewModel: TransactionsListViewModelDelegate {

    func didDelete(transactionsWith identifiers: Set<Transaction.ID>) {
        delegate?.didDelete(transactionsWith: identifiers)
    }
}
