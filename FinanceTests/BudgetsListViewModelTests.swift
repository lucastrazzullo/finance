//
//  BudgetsListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class BudgetsListViewModelTests: XCTestCase {

    private var viewModel: BudgetsListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Budgets

    func testDeleteBudgets() async throws {
        let budgets = Mocks.expenseBudgets

        viewModel = BudgetsListViewModel(budgets: budgets, addBudgets: {}, deleteBudgets: { _ in })

        // Assert initial state
        XCTAssertNil(viewModel.deleteBudgetError)
        budgets.forEach { budget in
            XCTAssertTrue(viewModel.budgets.contains(budget))
        }

        // Delete budgets
        let offsets = IndexSet(integersIn: 0..<budgets.count)
        await viewModel.delete(budgetsAt: offsets)

        XCTAssertNil(viewModel.deleteBudgetError)
        budgets.forEach { budget in
            XCTAssertFalse(viewModel.budgets.contains(budget))
        }
    }
}
