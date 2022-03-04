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

        let budget1 = try Budget(id: UUID(), name: "Test 1")
        let budget2 = try Budget(id: UUID(), name: "Test 2")
        var report = try await repository.add(budget: budget1)
        report = try await repository.add(budget: budget2)

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

        let report = try await repository.delete(budgetWith: budget1.id)

        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(report.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteMultipleBudgets() async throws {
        let budget1 = try Budget(id: UUID(), name: "Test 1")
        let budget2 = try Budget(id: UUID(), name: "Test 2")

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        var report = try await repository.delete(budgetWith: budget1.id)
        report = try await repository.delete(budgetWith: budget2.id)

        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertFalse(report.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteUnexistingBudget() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)
        let _ = try await repository.delete(budgetWith: UUID())
        let _ = try await repository.delete(budgetsWith: [UUID(), UUID()])
    }

    // MARK: - Update

    func testUpdateBudget() async throws {
        let budgetSlicesBeforeUpdate = [try BudgetSlice(id: UUID(), name: "Slice 1", configuration: .montly(amount: .value(100)))]
        let budgetSlicesAfterUpdate = [try BudgetSlice(id: UUID(), name: "Slice 2", configuration: .montly(amount: .value(200)))]

        let budgetBeforeUpdate = try Budget(id: UUID(), name: "Test", slices: budgetSlicesBeforeUpdate)

        storageProvider = MockStorageProvider(budgets: [budgetBeforeUpdate])
        repository = Repository(storageProvider: storageProvider)

        let budgetAfterUpdate = try Budget(id: budgetBeforeUpdate.id, name: budgetBeforeUpdate.name, slices: budgetSlicesAfterUpdate)
        let updatedBudget = try await repository.update(budget: budgetAfterUpdate)

        XCTAssertEqual(updatedBudget.id, budgetBeforeUpdate.id)
        XCTAssertEqual(updatedBudget.name, budgetBeforeUpdate.name)
        XCTAssertEqual(updatedBudget.slices, budgetSlicesAfterUpdate)
    }

    func testUpdateBudgetWithSameName() async throws {
        let budget1 = try Budget(id: UUID(), name: "Test 1", monthlyAmount: .value(100))
        let budget2 = try Budget(id: UUID(), name: "Test 2", monthlyAmount: .value(100))

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        let budgetAfterUpdate = try Budget(id: budget2.id, name: budget1.name, slices: budget2.slices)

        do {
            let _ = try await repository.update(budget: budgetAfterUpdate)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.report(error: .budgetAlreadyExistsWith(name: budget1.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }
}
