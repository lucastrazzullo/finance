//
//  RepositoryTests.swift
//  RepositoryTests
//
//  Created by Luca Strazzullo on 08/02/2022.
//

import XCTest
@testable import Finance

class RepositoryTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var repository: Repository!

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        repository = nil
        storageProvider = nil
    }

    // MARK: - Fetch

    func testFetchEmptyReport() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)

        let report = try await repository.fetchReport()
        XCTAssertTrue(report.budgets.isEmpty)
    }

    func testFetchBudget() async throws {
        let budgetId = UUID()
        let budget = try Budget(id: budgetId, name: "Test")

        storageProvider = MockStorageProvider(budgets: [budget])
        repository = Repository(storageProvider: storageProvider)

        let fetchedBudget = try await repository.fetch(budgetWith: budgetId)
        XCTAssertNotNil(fetchedBudget)
    }

    func testFetchUnesistingBudget() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)

        do {
            let _ = try await repository.fetch(budgetWith: .init())
            XCTFail("Expected error")
        } catch {
            guard case DomainError.storageProvider(error: .budgetEntityNotFound) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    // MARK: - Add

    func testAddBudget() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)

        let budget1 = try Budget(name: "Test 1")
        let budget2 = try Budget(name: "Test 2")
        try await repository.add(budget: budget1)
        try await repository.add(budget: budget2)

        let report = try await repository.fetchReport()
        XCTAssertTrue(report.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(report.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testAddBudgetWithSameName() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)

        let budget1 = try Budget(id: UUID(), name: "Test")
        let budget2 = try Budget(id: UUID(), name: "Test")

        do {
            let _ = try await repository.add(budget: budget1)
            let _ = try await repository.add(budget: budget2)
        } catch {
            guard case DomainError.report(error: .budgetAlreadyExistsWith(name: budget1.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    // MARK: - Delete

    func testDeleteBudget() async throws {
        let budget1 = try Budget(id: UUID(), name: "Test 1")
        let budget2 = try Budget(id: UUID(), name: "Test 2")

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        try await repository.delete(budgetsWith: [budget1.id])
        let report = try await repository.fetchReport()

        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(report.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteMultipleBudgets() async throws {
        let budget1 = try Budget(id: UUID(), name: "Test 1")
        let budget2 = try Budget(id: UUID(), name: "Test 2")

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        try await repository.delete(budgetsWith: [budget1.id, budget2.id])
        let report = try await repository.fetchReport()

        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteUnexistingBudget() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)
        try await repository.delete(budgetsWith: [UUID(), UUID()])
    }

    // MARK: - Update

    func testUpdateBudget_addSlices() async throws {
        let slice1 = try BudgetSlice(name: "Slice 1", configuration: .montly(amount: .value(100)))
        let slice2 = try BudgetSlice(name: "Slice 2", configuration: .montly(amount: .value(200)))
        let budget = try Budget(name: "Test", slices: [slice1])

        storageProvider = MockStorageProvider(budgets: [budget])
        repository = Repository(storageProvider: storageProvider)

        try await repository.add(slice: slice2, toBudgetWith: budget.id)
        let updatedBudget = try await repository.fetch(budgetWith: budget.id)

        XCTAssertEqual(updatedBudget.slices, [slice1, slice2])
    }

    func testUpdateBudgetWithSameName() async throws {
        let budget1 = try Budget(id: UUID(), name: "Test 1", monthlyAmount: .value(100))
        let budget2 = try Budget(id: UUID(), name: "Test 2", monthlyAmount: .value(100))

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        do {
            let _ = try await repository.update(name: budget2.name, inBudgetWith: budget1.id)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.report(error: .budgetAlreadyExistsWith(name: budget2.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }
}
