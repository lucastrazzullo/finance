//
//  FinanceSessionTests.swift
//  RepositoryTests
//
//  Created by Luca Strazzullo on 08/02/2022.
//

import XCTest
import Combine

@testable import Finance

@MainActor final class FinanceSessionTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var session: FinanceSession!
    private var subscriptions: Set<AnyCancellable>!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptions = []
    }

    @MainActor override func tearDownWithError() throws {
        session = nil
        storageProvider = nil
        subscriptions = []
        try super.tearDownWithError()
    }

    // MARK: - Start

    func testLoadSession() async throws {
        let budgets = Mocks.budgets
        let transactions = Mocks.transactions
        storageProvider = try MockStorageProvider(budgets: budgets, transactions: transactions)
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        XCTAssertEqual(session.overview.budgets, budgets)
        XCTAssertEqual(session.overview.expenses, transactions)
    }

    func testSessionNoStart() throws {
        let budgets = Mocks.budgets
        let transactions = Mocks.transactions
        storageProvider = try MockStorageProvider(budgets: budgets, transactions: transactions)
        session = FinanceSession(storageProvider: storageProvider)

        XCTAssertNotEqual(session.overview.budgets, budgets)
        XCTAssertNotEqual(session.overview.expenses, transactions)
    }

    // MARK: - Add

    func testAddBudget() async throws {
        storageProvider = MockStorageProvider()
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test 2", icon: .default, monthlyAmount: .value(100))
        try await session.add(budget: budget1)
        try await session.add(budget: budget2)

        XCTAssertTrue(session.overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(session.overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testAddBudgetWithSameName() async throws {
        storageProvider = MockStorageProvider()
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        let budget1 = try Budget(year: Mocks.year, name: "Test", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test", icon: .default, monthlyAmount: .value(100))

        do {
            let _ = try await session.add(budget: budget1)
            let _ = try await session.add(budget: budget2)
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget1.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    func testAddBudget_withDifferentYear() async throws {
        storageProvider = MockStorageProvider()
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        let budget = try Budget(year: Mocks.year - 1, name: "Test", icon: .default, monthlyAmount: .value(100))

        do {
            try await session.add(budget: budget)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetsListNotValid) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    func testAddTransaction_withDifferentYear() async throws {
        storageProvider = MockStorageProvider()
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        var components = DateComponents()
        components.year = Mocks.year - 1
        let date = try XCTUnwrap(Calendar.current.date(from: components))
        let transaction = Transaction(description: nil, amount: .value(100), date: date, budgetSliceId: .init())

        do {
            try await session.add(transactions: [transaction])
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .transactionsListNotValid) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    // MARK: - Delete

    func testDeleteBudget() async throws {
        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test 2", icon: .default, monthlyAmount: .value(100))

        storageProvider = try MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.delete(budgetsWith: [budget1.id])

        XCTAssertFalse(session.overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(session.overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteMultipleBudgets() async throws {
        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test 2", icon: .default, monthlyAmount: .value(100))

        storageProvider = try MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.delete(budgetsWith: [budget1.id, budget2.id])

        XCTAssertFalse(session.overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertFalse(session.overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteUnexistingBudget() async throws {
        storageProvider = try MockStorageProvider(budgets: [], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.delete(budgetsWith: [UUID(), UUID()])
    }

    // MARK: - Update

    func testUpdateBudget_addSlices() async throws {
        let slice1 = try BudgetSlice(name: "Slice 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(name: "Slice 2", configuration: .monthly(amount: .value(200)))
        let budget = try Budget(year: Mocks.year, name: "Test", icon: .default, slices: [slice1])

        storageProvider = try MockStorageProvider(budgets: [budget], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.add(slice: slice2, toBudgetWith: budget.id)

        let updatedBudget = try XCTUnwrap(session.overview.budgets.with(identifier: budget.id))
        XCTAssertEqual(updatedBudget.slices, [slice1, slice2])
    }

    func testUpdateBudget_name() async throws {
        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test 2", icon: .default, monthlyAmount: .value(100))

        storageProvider = try MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.update(name: "Test 3", icon: .default, inBudgetWith: budget1.id)
    }

    func testUpdateBudget_icon() async throws {
        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))

        storageProvider = try MockStorageProvider(budgets: [budget1], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()
        try await session.update(name: budget1.name, icon: .car, inBudgetWith: budget1.id)
    }

    func testUpdateBudget_withSameName() async throws {
        let budget1 = try Budget(year: Mocks.year, name: "Test 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(year: Mocks.year, name: "Test 2", icon: .default, monthlyAmount: .value(100))

        storageProvider = try MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        session = FinanceSession(storageProvider: storageProvider)
        try await session.load()

        do {
            try await session.update(name: budget2.name, icon: .default, inBudgetWith: budget1.id)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget2.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }
}
