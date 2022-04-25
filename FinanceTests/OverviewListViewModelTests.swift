//
//  OverviewListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class OverviewListViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: OverviewListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Expenses

    func testAddExpenses() async throws {
        let overview = YearlyBudgetOverview(name: "Mock", year: Mocks.year, budgets: [], expenses: [])
        storageProvider = MockStorageProvider()
        viewModel = OverviewListViewModel(month: 1, yearlyOverview: overview, storageProvider: storageProvider, delegate: nil)

        let expenses = Mocks.transactions

        viewModel.addNewTransactionIsPresented = true
        try await viewModel.add(expenses: expenses)

        XCTAssertFalse(viewModel.addNewTransactionIsPresented)
        XCTAssertEqual(viewModel.yearlyOverview.expenses, expenses)

        let storedExpenses = try await storageProvider.fetchTransactions(year: overview.year)
        expenses.forEach { transaction in
            XCTAssertTrue(storedExpenses.contains(transaction))
        }
    }
}
