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

    override func tearDownWithError() throws {
        repository = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Fetch

    func testFetchOverview() async throws {
        let year = 2022
        storageProvider = MockStorageProvider(overviewYear: year)
        repository = Repository(storageProvider: storageProvider)

        do {
            _ = try await repository.fetchYearlyOverview(year: year)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFetchUnexistingOverview() async throws {
        storageProvider = MockStorageProvider(overviewYear: 2022)
        repository = Repository(storageProvider: storageProvider)

        do {
            _ = try await repository.fetchYearlyOverview(year: 2021)
            XCTFail("Error expected")
        } catch {}
    }

    func testFetchBudget() async throws {
        let budgetId = UUID()
        let budget = try Budget(id: budgetId, year: 2022, name: "Test", icon: .none)

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
        let year = 2022

        storageProvider = MockStorageProvider(overviewYear: year)
        repository = Repository(storageProvider: storageProvider)

        let budget1 = try Budget(year: year, name: "Test 1", icon: .none)
        let budget2 = try Budget(year: year, name: "Test 2", icon: .none)
        try await repository.add(budget: budget1)
        try await repository.add(budget: budget2)

        let overview = try await repository.fetchYearlyOverview(year: year )
        XCTAssertTrue(overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testAddBudgetWithSameName() async throws {
        let year = 2022

        storageProvider = MockStorageProvider(overviewYear: year)
        repository = Repository(storageProvider: storageProvider)

        let budget1 = try Budget(year: year, name: "Test", icon: .none)
        let budget2 = try Budget(year: year, name: "Test", icon: .none)

        do {
            let _ = try await repository.add(budget: budget1)
            let _ = try await repository.add(budget: budget2)
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget1.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }

    // MARK: - Delete

    func testDeleteBudget() async throws {
        let year = 2022
        let budget1 = try Budget(year: year, name: "Test 1", icon: .none)
        let budget2 = try Budget(year: year, name: "Test 2", icon: .none)

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        try await repository.delete(budgetsWith: [budget1.id])
        let overview = try await repository.fetchYearlyOverview(year: year)

        XCTAssertFalse(overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertTrue(overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteMultipleBudgets() async throws {
        let year = 2022
        let budget1 = try Budget(year: year, name: "Test 1", icon: .none)
        let budget2 = try Budget(year: year, name: "Test 2", icon: .none)

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        try await repository.delete(budgetsWith: [budget1.id, budget2.id])
        let overview = try await repository.fetchYearlyOverview(year: year)

        XCTAssertFalse(overview.budgets.contains(where: { $0.id == budget1.id }))
        XCTAssertFalse(overview.budgets.contains(where: { $0.id == budget2.id }))
    }

    func testDeleteUnexistingBudget() async throws {
        storageProvider = MockStorageProvider(budgets: [])
        repository = Repository(storageProvider: storageProvider)

        do {
            try await repository.delete(budgetsWith: [UUID(), UUID()])
            XCTFail("Error expected")
        } catch {}
    }

    // MARK: - Update

    func testUpdateBudget_addSlices() async throws {
        let year = 2022
        let slice1 = try BudgetSlice(name: "Slice 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(name: "Slice 2", configuration: .monthly(amount: .value(200)))
        let budget = try Budget(year: year, name: "Test", icon: .none, slices: [slice1])

        storageProvider = MockStorageProvider(budgets: [budget])
        repository = Repository(storageProvider: storageProvider)

        try await repository.add(slice: slice2, toBudgetWith: budget.id)
        let updatedBudget = try await repository.fetch(budgetWith: budget.id)

        XCTAssertEqual(updatedBudget.slices, [slice1, slice2])
    }

    func testUpdateBudget_name() async throws {
        let year = 2022
        let budget1 = try Budget(year: year, name: "Test 1", icon: .none, monthlyAmount: .value(100))
        let budget2 = try Budget(year: year, name: "Test 2", icon: .none, monthlyAmount: .value(100))

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        let _ = try await repository.update(name: "Test 3", iconSystemName: nil, inBudgetWith: budget1.id)
    }

    func testUpdateBudget_icon() async throws {
        let year = 2022
        let budget1 = try Budget(year: year, name: "Test 1", icon: .none, monthlyAmount: .value(100))

        storageProvider = MockStorageProvider(budgets: [budget1])
        repository = Repository(storageProvider: storageProvider)

        let _ = try await repository.update(name: budget1.name, iconSystemName: "leaf", inBudgetWith: budget1.id)
    }

    func testUpdateBudget_withSameName() async throws {
        let year = 2022
        let budget1 = try Budget(year: year, name: "Test 1", icon: .none, monthlyAmount: .value(100))
        let budget2 = try Budget(year: year, name: "Test 2", icon: .none, monthlyAmount: .value(100))

        storageProvider = MockStorageProvider(budgets: [budget1, budget2])
        repository = Repository(storageProvider: storageProvider)

        do {
            let _ = try await repository.update(name: budget2.name, iconSystemName: "leaf", inBudgetWith: budget1.id)
            XCTFail("Error expected")
        } catch {
            guard case DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget2.name)) = error else {
                XCTFail("Expected different error than \(error)")
                return
            }
        }
    }
}
