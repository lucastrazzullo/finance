//
//  FinanceViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class FinanceViewModelTests: XCTestCase {

    private var viewModel: FinanceViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Load

    func testLoad() async throws {
        let budgets = Mocks.allBudgets
        let transactions = Mocks.allTransactions
        let storageProvider = MockStorageProvider(budgets: budgets, transactions: transactions)
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)

        try await viewModel.load()
        XCTAssertEqual(viewModel.yearlyOverview.budgets, budgets)
        XCTAssertEqual(viewModel.yearlyOverview.transactions, transactions)
    }

    func testNoLoad() throws {
        let budgets = Mocks.allBudgets
        let transactions = Mocks.allTransactions
        let storageProvider = MockStorageProvider(budgets: budgets, transactions: transactions)
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)

        XCTAssertNotEqual(viewModel.yearlyOverview.budgets, budgets)
        XCTAssertNotEqual(viewModel.yearlyOverview.transactions, transactions)
    }

    // MARK: - Budgets List Data Provider

    func testAddBudget_valid() async throws {
        let budget = Mocks.expenseBudgets[0]
        let storageProvider = MockStorageProvider()
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)
        try await viewModel.load()

        viewModel.isAddNewBudgetPresented = true
        try await viewModel.add(budget: budget)

        XCTAssertFalse(viewModel.isAddNewBudgetPresented)
        XCTAssertTrue(viewModel.yearlyOverview.budgets.contains(budget))

        let storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.yearlyOverview.year)
        XCTAssertTrue(storedBudgets.contains(budget))
    }

    func testAddBudget_invalid() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget3 = try Budget(id: .init(), year: Mocks.year - 1, kind: .expense, name: "Name 3", icon: .default, monthlyAmount: .value(100))
        let storageProvider = MockStorageProvider(budgets: [budget1], transactions: [])
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)
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
        XCTAssertTrue(viewModel.yearlyOverview.budgets.contains(budget1))

        var storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.yearlyOverview.year)
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
        XCTAssertFalse(viewModel.yearlyOverview.budgets.contains(budget2))

        storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.yearlyOverview.year)
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
        XCTAssertFalse(viewModel.yearlyOverview.budgets.contains(budget3))

        storedBudgets = try await storageProvider.fetchBudgets(year: viewModel.yearlyOverview.year)
        XCTAssertFalse(storedBudgets.contains(budget3))
    }

    func testDeleteBudgets_valid() async throws {
        let budgetToDelete = Mocks.expenseBudgets[0]
        let storageProvider = MockStorageProvider(budgets: Mocks.expenseBudgets, transactions: [])
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)

        try await viewModel.load()
        XCTAssertTrue(viewModel.yearlyOverview.budgets.contains(budgetToDelete))

        try await viewModel.delete(budgetsWith: [budgetToDelete.id])
        XCTAssertFalse(viewModel.yearlyOverview.budgets.contains(budgetToDelete))
    }

    func testDeleteBudgets_invalid() async throws {
        let budgetToDelete = Mocks.expenseBudgets[0]
        let otherBudget = Mocks.expenseBudgets[1]
        let storageProvider = MockStorageProvider(budgets: [otherBudget], transactions: [])
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)

        try await viewModel.load()
        XCTAssertFalse(viewModel.yearlyOverview.budgets.contains(budgetToDelete))

        try await viewModel.delete(budgetsWith: [budgetToDelete.id])
        XCTAssertNil(viewModel.yearlyOverview.budgets.with(identifier: budgetToDelete.id))
    }

    // MARK: - Overview List Data Provider

    func testAddExpenses_valid() async throws {
        let date = Date.with(year: Mocks.year, month: 1, day: 1)!

        let expense1 = try Transaction(id: .init(), description: nil, date: date, amounts: [.init(amount: .value(100), budgetKind: .expense, budgetIdentifier: .init(), sliceIdentifier: .init())])
        let expense2 = try Transaction(id: .init(), description: nil, date: date, amounts: [.init(amount: .value(100), budgetKind: .expense, budgetIdentifier: .init(), sliceIdentifier: .init())])
        let storageProvider = MockStorageProvider(budgets: [], transactions: [])
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)
        try await viewModel.load()

        try await viewModel.add(transactions: [expense1, expense2])
        XCTAssertNotNil(viewModel.yearlyOverview.transactions.with(identifier: expense1.id))
        XCTAssertNotNil(viewModel.yearlyOverview.transactions.with(identifier: expense2.id))
    }

    func testAddExpenses_invalid() async throws {
        let date = Date.with(year: Mocks.year - 1, month: 1, day: 1)!
        let expense = try Transaction(id: .init(), description: nil, date: date, amounts: [.init(amount: .value(100), budgetKind: .expense, budgetIdentifier: .init(), sliceIdentifier: .init())])
        let storageProvider = MockStorageProvider(budgets: [], transactions: [])
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)
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

    func testDeleteExpenses() async throws {
        let transactionsToDelete = Mocks.allTransactions[0]
        let storageProvider = MockStorageProvider(budgets: [], transactions: Mocks.allTransactions)
        let finance = Finance(storageProvider: storageProvider)
        viewModel = FinanceViewModel(year: Mocks.year, openingBalance: .zero, storageHandler: finance)
        try await viewModel.load()

        XCTAssertTrue(viewModel.yearlyOverview.transactions.contains(transactionsToDelete))

        try await viewModel.delete(transactionsWith: [transactionsToDelete.id])
        XCTAssertFalse(viewModel.yearlyOverview.transactions.contains(transactionsToDelete))
    }
}
