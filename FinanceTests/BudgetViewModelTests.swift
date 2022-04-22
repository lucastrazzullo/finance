//
//  BudgetViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class BudgetViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: BudgetViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Slices

    func testAddSlice() async throws {
        let budget = Mocks.budgets[0]
        let slice = try BudgetSlice(name: "Adding slice", configuration: .monthly(amount: .value(100)))

        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = BudgetViewModel(budget: budget, storageProvider: storageProvider, delegate: nil)

        XCTAssertFalse(budget.slices.contains(slice))

        viewModel.isInsertNewSlicePresented = true
        try await viewModel.add(slice: slice)

        XCTAssertFalse(viewModel.isInsertNewSlicePresented)
        XCTAssertTrue(viewModel.slices.contains(slice))

        let storedBudgets = try await storageProvider.fetchBudgets(year: budget.year)
        let storedBudget = try XCTUnwrap(storedBudgets.with(identifier: budget.id))
        XCTAssertTrue(storedBudget.slices.contains(slice))
    }

    func testDeleteSlices() async throws {
        let slicesToDelete = Mocks.houseSlices
        let slicesWillRemain = Mocks.groceriesSlices
        let slices = slicesToDelete + slicesWillRemain
        let budget = try Budget(year: Mocks.year, name: "Name", icon: .default, slices: slices)
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = BudgetViewModel(budget: budget, storageProvider: storageProvider, delegate: nil)

        XCTAssertNil(viewModel.deleteSlicesError)
        slicesToDelete.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }
        slicesWillRemain.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }

        await viewModel.delete(slicesAt: .init(integersIn: 0..<slicesToDelete.count))

        XCTAssertNil(viewModel.deleteSlicesError)
        slicesToDelete.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        slicesWillRemain.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }

        let storedBudgets = try await storageProvider.fetchBudgets(year: budget.year)
        let storedBudget = try XCTUnwrap(storedBudgets.with(identifier: budget.id))
        slicesToDelete.forEach { slice in
            XCTAssertFalse(storedBudget.slices.contains(slice))
        }
        slicesWillRemain.forEach { slice in
            XCTAssertTrue(storedBudget.slices.contains(slice))
        }
    }

    func testSaveUpdates() async throws {
        let budget = try Budget(year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = BudgetViewModel(budget: budget, storageProvider: storageProvider, delegate: nil)

        XCTAssertNil(viewModel.deleteSlicesError)

        viewModel.updatingBudgetName = "Name 2"
        viewModel.updatingBudgetIcon = .car
        await viewModel.saveUpdates()

        XCTAssertEqual(viewModel.budget.name, "Name 2")
        XCTAssertEqual(viewModel.budget.icon, .car)
        XCTAssertNil(viewModel.deleteSlicesError)

        let storedBudgets = try await storageProvider.fetchBudgets(year: budget.year)
        let storedBudget = try XCTUnwrap(storedBudgets.with(identifier: budget.id))
        XCTAssertEqual(storedBudget.name, "Name 2")
        XCTAssertEqual(storedBudget.icon, .car)
    }
}
