//
//  YearlyOverviewViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class YearlyOverviewViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: YearlyOverviewViewModel!

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
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)

        try await viewModel.load()

        XCTAssertEqual(viewModel.yearlyOverview.budgets, budgets)
        XCTAssertEqual(viewModel.yearlyOverview.expenses, transactions)
    }

    func testNoLoad() throws {
        let budgets = Mocks.budgets
        let transactions = Mocks.transactions
        storageProvider = MockStorageProvider(budgets: budgets, transactions: transactions)
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)

        XCTAssertNotEqual(viewModel.yearlyOverview.budgets, budgets)
        XCTAssertNotEqual(viewModel.yearlyOverview.expenses, transactions)
    }

    // MARK: - Budget data provider

    func testAddSlice() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name", icon: .default, slices: [slice1])
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()
        try await viewModel.add(slice: slice2, toBudgetWith: budget.id)

        let updatedBudget = try await viewModel.budget(with: budget.id)
        XCTAssertNotNil(updatedBudget.slices.with(identifier: slice2.id))
    }

    func testDeleteSlices() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, name: "Name", icon: .default, slices: [slice1, slice2])
        storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        // Delete slice 1
        try await viewModel.delete(slicesWith: [slice1.id], inBudgetWith: budget.id)
        var updatedBudget = try await viewModel.budget(with: budget.id)
        XCTAssertNil(updatedBudget.slices.with(identifier: slice1.id))

        // Delete slice 2
        try? await viewModel.delete(slicesWith: [slice2.id], inBudgetWith: budget.id)
        updatedBudget = try await viewModel.budget(with: budget.id)
        XCTAssertNotNil(updatedBudget.slices.with(identifier: slice2.id))
    }

    func testUpdateNameInBudget() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, name: "Name 2", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        // Update with same name
        try await viewModel.update(name: "Name 1", icon: .car, in: budget1)
        var updatedBudget = try await viewModel.budget(with: budget1.id)
        updatedBudget = try XCTUnwrap(updatedBudget)
        XCTAssertEqual(updatedBudget.name, "Name 1")
        XCTAssertEqual(updatedBudget.icon, .car)

        // Update with different name
        try await viewModel.update(name: "Name 3", icon: .default, in: budget1)
        updatedBudget = try await viewModel.budget(with: budget1.id)
        updatedBudget = try XCTUnwrap(updatedBudget)
        XCTAssertEqual(updatedBudget.name, "Name 3")
        XCTAssertEqual(updatedBudget.icon, .default)

        // Update with same name as another budget
        do {
            try await viewModel.update(name: "Name 2", icon: .car, in: budget1)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: "Name 2")) = error else {
                XCTFail("Different error thrown: \(error)")
                return
            }
        }
        XCTAssertEqual(updatedBudget.name, "Name 3")
        XCTAssertEqual(updatedBudget.icon, .default)
    }

    // MARK: - Budgets List Data Provider

    func testAddBudget_valid() async throws {
        let budget = Mocks.budgets[0]
        storageProvider = MockStorageProvider()
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()
        try await viewModel.add(budget: budget)

        XCTAssertTrue(viewModel.budgets.contains(budget))

        let storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.year)
        XCTAssertTrue(storedBudgets.contains(budget))
    }

    func testAddBudget_invalid() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget3 = try Budget(id: .init(), year: Mocks.year - 1, name: "Name 3", icon: .default, monthlyAmount: .value(100))
        storageProvider = MockStorageProvider(budgets: [budget1], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        // Budget that was already in the list
        do {
            try await viewModel.add(budget: budget1)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget1.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
        XCTAssertTrue(viewModel.budgets.contains(budget1))

        var storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.year)
        XCTAssertTrue(storedBudgets.contains(budget1))

        // Budget that has the same name
        do {
            try await viewModel.add(budget: budget2)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget2.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
        XCTAssertFalse(viewModel.budgets.contains(budget2))

        storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.year)
        XCTAssertFalse(storedBudgets.contains(budget2))

        // Budget with different year
        do {
            try await viewModel.add(budget: budget3)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .cannotAddBudget) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
        XCTAssertFalse(viewModel.budgets.contains(budget3))

        storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.year)
        XCTAssertFalse(storedBudgets.contains(budget3))
    }

    func testDeleteBudgets_valid() async throws {
        let budgetToDelete = Mocks.budgets[0]
        storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)

        try await viewModel.load()
        XCTAssertTrue(viewModel.budgets.contains(budgetToDelete))

        try await viewModel.delete(budgetsWith: [budgetToDelete.id])
        XCTAssertFalse(viewModel.budgets.contains(budgetToDelete))
    }

    func testDeleteBudgets_invalid() async throws {
        let budgetToDelete = Mocks.budgets[0]
        let otherBudget = Mocks.budgets[1]
        storageProvider = MockStorageProvider(budgets: [otherBudget], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)

        try await viewModel.load()
        XCTAssertFalse(viewModel.budgets.contains(budgetToDelete))

        try await viewModel.delete(budgetsWith: [budgetToDelete.id])
        XCTAssertNil(viewModel.budgets.with(identifier: budgetToDelete.id))
    }

    // MARK: - Overview List Data Provider

    func testAddExpenses_invalid() async throws {
        var components = DateComponents()
        components.year = Mocks.year - 1
        let date = Calendar.current.date(from: components)!
        let expense = Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: .init())
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        do {
            try await viewModel.add(transactions: [expense])
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .transactionsListNotValid) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    func testAddExpenses_valid() async throws {
        var components = DateComponents()
        components.year = Mocks.year
        let date = Calendar.current.date(from: components)!

        let expense1 = Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: .init())
        let expense2 = Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: .init())
        storageProvider = MockStorageProvider(budgets: [], transactions: [])
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        try await viewModel.add(transactions: [expense1, expense2])
        XCTAssertNotNil(viewModel.transactions.with(identifier: expense1.id))
        XCTAssertNotNil(viewModel.transactions.with(identifier: expense2.id))
    }

    func testDeleteExpenses() async throws {
        let expensesToDelete = Mocks.transactions[0]
        storageProvider = MockStorageProvider(budgets: [], transactions: Mocks.transactions)
        viewModel = YearlyOverviewViewModel(year: Mocks.year, storageProvider: storageProvider)
        try await viewModel.load()

        XCTAssertTrue(viewModel.transactions.contains(expensesToDelete))

        try await viewModel.delete(transactionsAt: .init(integer: 0))
        XCTAssertFalse(viewModel.transactions.contains(expensesToDelete))
    }
}
