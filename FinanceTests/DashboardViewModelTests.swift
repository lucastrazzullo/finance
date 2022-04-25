//
//  DashboardViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class DashboardViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: DashboardViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Load

    func testLoad() async throws {
        let budgets = Mocks.budgets
        let transactions = Mocks.transactions
        storageProvider = MockStorageProvider(budgets: budgets, transactions: transactions)
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)

        try await viewModel.load()

        XCTAssertEqual(viewModel.budgets, budgets)
        XCTAssertEqual(viewModel.expenses, transactions)
    }

    func testNoLoad() throws {
        let budgets = Mocks.budgets
        let transactions = Mocks.transactions
        storageProvider = MockStorageProvider(budgets: budgets, transactions: transactions)
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)

        XCTAssertNotEqual(viewModel.budgets, budgets)
        XCTAssertNotEqual(viewModel.expenses, transactions)
    }

    // MARK: - BudgetViewModel delegate

    func testDidAddSliceInBudget() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name", icon: .default, slices: [slice1])
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        XCTAssertNoThrow(try viewModel.didAdd(slice: slice2, toBudgetWith: budget.id))

        let updatedBudget = try XCTUnwrap(viewModel.budgets.with(identifier: budget.id))
        XCTAssertNotNil(updatedBudget.slices.with(identifier: slice2.id))
    }

    func testDidDeleteSlicesFromBudget() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name", icon: .default, slices: [slice1, slice2])
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        // Delete slice 1
        XCTAssertNoThrow(try viewModel.didDelete(slicesWith: [slice1.id], inBudgetWith: budget.id))
        XCTAssertNil(viewModel.budgets.with(identifier: budget.id)?.slices.with(identifier: slice1.id))

        // Delete slice 2
        XCTAssertThrowsError(try viewModel.didDelete(slicesWith: [slice2.id], inBudgetWith: budget.id))
        XCTAssertNotNil(viewModel.budgets.with(identifier: budget.id)?.slices.with(identifier: slice2.id))
    }

    func testWillUpdateNameInBudget() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, name: "Name 2", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        XCTAssertNoThrow(try viewModel.willUpdate(name: "Name 1", in: budget1))
        XCTAssertThrowsError(try viewModel.willUpdate(name: "Name 2", in: budget1))
        XCTAssertNoThrow(try viewModel.willUpdate(name: "Name 3", in: budget1))

    }

    func testDidUpdateNameAndIconInBudget() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, name: "Name 2", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        try viewModel.didUpdate(name: "Name 3", icon: .car, inBudgetWith: budget1.id)

        let updatedBudget1 = try XCTUnwrap(viewModel.budgets.with(identifier: budget1.id))
        XCTAssertEqual(updatedBudget1.name, "Name 3")
        XCTAssertEqual(updatedBudget1.icon, .car)
    }

    // MARK: - BudgetsListViewModel delegate

    func testWillAddBudget() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, name: "Name 2", icon: .default, monthlyAmount: .value(100))
        let budget3 = try Budget(id: .init(), year: Mocks.year - 1, name: "Name 3", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget2], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        // Budget that was not in the list already
        XCTAssertNoThrow(try viewModel.willAdd(budget: budget1))

        // Budget that was already in the list, hence same name
        XCTAssertThrowsError(try viewModel.willAdd(budget: budget2)) { error in
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget2.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }

        // Budget with different year
        XCTAssertThrowsError(try viewModel.willAdd(budget: budget3)) { error in
            guard case DomainError.budgetOverview(error: .cannotAddBudget) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    func testDidAddBudget() async throws {
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        try viewModel.didAdd(budget: budget)
        XCTAssertNotNil(viewModel.budgets.with(identifier: budget.id))
    }

    func testDidDeleteBudgets() async throws {
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        viewModel.didDelete(budgetsWith: [budget.id])
        XCTAssertNil(viewModel.budgets.with(identifier: budget.id))
    }

    // MARK: - OverviewListView delegate

    func testWillAddExpenses() async throws {
        var components = DateComponents()
        components.year = Mocks.year
        let date1 = Calendar.current.date(from: components)!
        components.year = Mocks.year - 1
        let date2 = Calendar.current.date(from: components)!
        let expense1 = Transaction(id: .init(), description: nil, amount: .value(100), date: date1, budgetSliceId: .init())
        let expense2 = Transaction(id: .init(), description: nil, amount: .value(100), date: date2, budgetSliceId: .init())
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        XCTAssertNoThrow(try viewModel.willAdd(expenses: [expense1]))
        XCTAssertThrowsError(try viewModel.willAdd(expenses: [expense2])) { error in
            guard case DomainError.budgetOverview(error: .transactionsListNotValid) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    func testDidAddExpenses() async throws {
        var components = DateComponents()
        components.year = Mocks.year
        let date = Calendar.current.date(from: components)!

        let expense1 = Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: .init())
        let expense2 = Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: .init())
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = DashboardViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        try viewModel.didAdd(expenses: [expense1, expense2])
        XCTAssertNotNil(viewModel.expenses.with(identifier: expense1.id))
        XCTAssertNotNil(viewModel.expenses.with(identifier: expense2.id))
    }
}
