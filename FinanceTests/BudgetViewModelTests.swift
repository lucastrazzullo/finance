//
//  BudgetViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class BudgetViewModelTests: XCTestCase {

    private var dataProvider: BudgetDataProvider!
    private var viewModel: BudgetViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        dataProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Slices

    func testAddSlice() async throws {
        let budget = Mocks.budgets[0]
        let slice = try BudgetSlice(id: .init(), name: "Adding slice", configuration: .monthly(amount: .value(100)))

        dataProvider = MockBudgetDataProvider(budgets: [budget])
        viewModel = BudgetViewModel(budget: budget, dataProvider: dataProvider)

        XCTAssertFalse(budget.slices.contains(slice))

        viewModel.isInsertNewSlicePresented = true
        try await viewModel.add(slice: slice)

        XCTAssertFalse(viewModel.isInsertNewSlicePresented)
        XCTAssertTrue(viewModel.slices.contains(slice))

        let updatedBudget = try await dataProvider.budget(with: budget.id)
        XCTAssertTrue(updatedBudget.slices.contains(slice))
    }

    func testDeleteSlices() async throws {
        let firstSlicesSet = Mocks.houseSlices
        let secondSlicesSet = Mocks.groceriesSlices
        let extraSlice = try BudgetSlice(id: .init(), name: "Extra slice", configuration: .monthly(amount: .value(100)))
        let slices = firstSlicesSet + secondSlicesSet + [extraSlice]
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name", icon: .default, slices: slices)

        dataProvider = MockBudgetDataProvider(budgets: [budget])
        viewModel = BudgetViewModel(budget: budget, dataProvider: dataProvider)

        // Assert initial state
        XCTAssertNil(viewModel.deleteSlicesError)
        firstSlicesSet.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }
        XCTAssertTrue(viewModel.budget.slices.contains(extraSlice))

        // Delete first slices set
        var offsets = IndexSet(integersIn: 0..<firstSlicesSet.count)
        await viewModel.delete(slicesAt: offsets)

        XCTAssertNil(viewModel.deleteSlicesError)
        firstSlicesSet.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertTrue(viewModel.budget.slices.contains(slice))
        }
        XCTAssertTrue(viewModel.budget.slices.contains(extraSlice))

        var updatedBudget = try await dataProvider.budget(with: budget.id)
        firstSlicesSet.forEach { slice in
            XCTAssertFalse(updatedBudget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertTrue(updatedBudget.slices.contains(slice))
        }
        XCTAssertTrue(updatedBudget.slices.contains(extraSlice))

        // Delete second slices set
        offsets = IndexSet(integersIn: 0..<secondSlicesSet.count)
        await viewModel.delete(slicesAt: offsets)

        XCTAssertNil(viewModel.deleteSlicesError)
        firstSlicesSet.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        XCTAssertTrue(viewModel.budget.slices.contains(extraSlice))

        updatedBudget = try await dataProvider.budget(with: budget.id)
        firstSlicesSet.forEach { slice in
            XCTAssertFalse(updatedBudget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertFalse(updatedBudget.slices.contains(slice))
        }
        XCTAssertTrue(updatedBudget.slices.contains(extraSlice))

        // Delete extra slice
        offsets = IndexSet(integer: 0)
        await viewModel.delete(slicesAt: offsets)

        let error = try XCTUnwrap(viewModel.deleteSlicesError)
        guard case DomainError.budget(error: .thereMustBeAtLeastOneSlice) = error else {
            XCTFail("Error not expected: \(error)")
            return
        }

        firstSlicesSet.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertFalse(viewModel.budget.slices.contains(slice))
        }
        XCTAssertTrue(viewModel.budget.slices.contains(extraSlice))

        updatedBudget = try await dataProvider.budget(with: budget.id)
        firstSlicesSet.forEach { slice in
            XCTAssertFalse(updatedBudget.slices.contains(slice))
        }
        secondSlicesSet.forEach { slice in
            XCTAssertFalse(updatedBudget.slices.contains(slice))
        }
        XCTAssertTrue(updatedBudget.slices.contains(extraSlice))
    }

    func testSaveUpdates() async throws {
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        dataProvider = MockBudgetDataProvider(budgets: [budget])
        viewModel = BudgetViewModel(budget: budget, dataProvider: dataProvider)

        XCTAssertNil(viewModel.deleteSlicesError)

        // Update to valid name and icon
        viewModel.updatingBudgetName = "Name 2"
        viewModel.updatingBudgetIcon = .car
        await viewModel.saveUpdates()

        XCTAssertNil(viewModel.deleteSlicesError)
        XCTAssertEqual(viewModel.budget.name, "Name 2")
        XCTAssertEqual(viewModel.budget.icon, .car)

        var updatedBudget = try await dataProvider.budget(with: budget.id)
        XCTAssertEqual(updatedBudget.name, "Name 2")
        XCTAssertEqual(updatedBudget.icon, .car)

        // Update to not valid name
        viewModel.updatingBudgetName = ""
        viewModel.updatingBudgetIcon = .car
        await viewModel.saveUpdates()

        let error = try XCTUnwrap(viewModel.updateBudgetInfoError)
        guard case DomainError.budget(error: .nameNotValid) = error else {
            XCTFail("Error not expected: \(error)")
            return
        }

        XCTAssertEqual(viewModel.budget.name, "Name 2")
        XCTAssertEqual(viewModel.budget.icon, .car)

        updatedBudget = try await dataProvider.budget(with: budget.id)
        XCTAssertEqual(updatedBudget.name, "Name 2")
        XCTAssertEqual(updatedBudget.icon, .car)
    }
}
