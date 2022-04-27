//
//  BudgetsListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class BudgetsListViewModelTests: XCTestCase {

    private var dataProvider: BudgetsListDataProvider!
    private var viewModel: BudgetsListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        dataProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Budgets

    func testAddBudget() async throws {
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Mock", icon: .default, monthlyAmount: .value(100))

        dataProvider = MockBudgetsListDataProvider(budgets: [])
        viewModel = BudgetsListViewModel(dataProvider: dataProvider)

        XCTAssertFalse(viewModel.budgets.contains(budget))

        viewModel.isAddNewBudgetPresented = true
        try await viewModel.add(budget: budget)

        XCTAssertFalse(viewModel.isAddNewBudgetPresented)
        XCTAssertTrue(viewModel.budgets.contains(budget))
        XCTAssertTrue(dataProvider.budgets.contains(budget))
    }

    func testDeleteBudgets() async throws {
        let budgets = Mocks.budgets

        dataProvider = MockBudgetsListDataProvider(budgets: budgets)
        viewModel = BudgetsListViewModel(dataProvider: dataProvider)

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
