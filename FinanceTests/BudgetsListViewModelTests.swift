//
//  BudgetsListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class BudgetsListViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: BudgetsListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Budgets

    func testAddBudget() async throws {
        let budget = Mocks.budgets[0]
        storageProvider = MockStorageProvider()
        viewModel = BudgetsListViewModel(year: Mocks.year, title: "Title", budgets: [], storageProvider: storageProvider, delegate: nil)

        viewModel.addNewBudgetIsPresented = true
        try await viewModel.add(budget: budget)

        XCTAssertFalse(viewModel.addNewBudgetIsPresented)
        XCTAssertTrue(viewModel.budgets.contains(budget))

        let storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.year)
        XCTAssertTrue(storedBudgets.contains(budget))
    }

    func testDeleteBudgets() async throws {
        let budgetToDelete = Mocks.budgets[0]
        storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: [])
        viewModel = BudgetsListViewModel(year: Mocks.year, title: "Title", budgets: Mocks.budgets, storageProvider: storageProvider, delegate: nil)

        XCTAssertNil(viewModel.deleteBudgetError)
        XCTAssertTrue(viewModel.budgets.contains(budgetToDelete))

        await viewModel.delete(budgetsAt: .init(integer: 0))

        XCTAssertNil(viewModel.deleteBudgetError)
        XCTAssertFalse(viewModel.budgets.contains(budgetToDelete))
    }
}
