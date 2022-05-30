//
//  FinanceTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 30/05/2022.
//

import XCTest
@testable import Finance

final class FinancesTests: XCTestCase {

    private var finance: Finance!

    // MARK: - Test life cycle

    @MainActor override func tearDownWithError() throws {
        finance = nil
        try super.tearDownWithError()
    }

    // MARK: - Budget data provider

    func testAddSlice() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name", icon: .default, slices: [slice1])
        let storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        finance = Finance(storageProvider: storageProvider)

        try await finance.add(slice: slice2, toBudgetWith: budget.id)
        let updatedBudget = try await finance.fetchBudget(with: budget.id)
        XCTAssertNotNil(updatedBudget.slices.with(identifier: slice2.id))
    }

    func testDeleteSlices() async throws {
        let slice1 = try BudgetSlice(id: .init(), name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try BudgetSlice(id: .init(), name: "Name 2", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name", icon: .default, slices: [slice1, slice2])
        let storageProvider = MockStorageProvider(budgets: [budget], transactions: [])
        finance = Finance(storageProvider: storageProvider)

        // Delete slice 1
        try await finance.delete(slicesWith: [slice1.id], inBudgetWith: budget.id)
        var updatedBudget = try await finance.fetchBudget(with: budget.id)
        XCTAssertNil(updatedBudget.slices.with(identifier: slice1.id))

        // Delete slice 2
        try? await finance.delete(slicesWith: [slice2.id], inBudgetWith: budget.id)
        updatedBudget = try await finance.fetchBudget(with: budget.id)
        XCTAssertNotNil(updatedBudget.slices.with(identifier: slice2.id))
    }

    func testUpdateNameInBudget() async throws {
        let budget1 = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name 1", icon: .default, monthlyAmount: .value(100))
        let budget2 = try Budget(id: .init(), year: Mocks.year, kind: .expense, name: "Name 2", icon: .default, monthlyAmount: .value(100))
        let storageProvider = MockStorageProvider(budgets: [budget1, budget2], transactions: [])
        finance = Finance(storageProvider: storageProvider)

        // Update with same name
        try await finance.update(name: "Name 1", icon: .car, in: budget1)
        var updatedBudget = try await finance.fetchBudget(with: budget1.id)
        XCTAssertEqual(updatedBudget.name, "Name 1")
        XCTAssertEqual(updatedBudget.icon, .car)

        // Update with different name
        try await finance.update(name: "Name 3", icon: .default, in: budget1)
        updatedBudget = try await finance.fetchBudget(with: budget1.id)
        XCTAssertEqual(updatedBudget.name, "Name 3")
        XCTAssertEqual(updatedBudget.icon, .default)

        // Update with same name as another budget
        do {
            try await finance.update(name: "Name 2", icon: .car, in: budget1)
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
}
