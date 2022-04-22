//
//  BudgetTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 09/04/2022.
//

import XCTest
@testable import Finance

final class BudgetTests: XCTestCase {

    // MARK: Factories

    private func makeSlice(name: String = "Name", configuration: BudgetSlice.Configuration = .monthly(amount: .value(100))) throws -> BudgetSlice {
        return try BudgetSlice(name: name, configuration: configuration)
    }

    private func makeBudget(year: Int = 2000, name: String = "Name", icon: SystemIcon = .default, slices: [BudgetSlice]? = nil) throws -> Budget {
        let budgetSlices: [BudgetSlice]
        if let slices = slices {
            budgetSlices = slices
        } else {
            budgetSlices = [
                try makeSlice(name: "Name 1"),
                try makeSlice(name: "Name 2")
            ]
        }
        return try Budget(year: year, name: name, icon: icon, slices: budgetSlices)
    }

    // MARK: Instantiating

    func testInstantiateBudget_withValidData() {
        XCTAssertNoThrow(try Budget(year: 2000, name: "Name", icon: .cat, monthlyAmount: .value(100)))
        XCTAssertNoThrow(try Budget(year: 2000, name: "Name", icon: .default, monthlyAmount: .value(100)))
        XCTAssertNoThrow(try Budget(year: 2000, name: "Name", icon: .default, slices: [
            try makeSlice(name: "Name"),
        ]))
        XCTAssertNoThrow(try Budget(year: 2000, name: "Name", icon: .default, slices: [
            try makeSlice(name: "Name 1"),
            try makeSlice(name: "Name 2")
        ]))
    }

    func testInstantiateBudget_withInvalidData() {
        XCTAssertThrowsError(try Budget(year: 2000, name: "", icon: .default, monthlyAmount: .value(100)))
        XCTAssertThrowsError(try Budget(year: 2000, name: "Name", icon: .default, monthlyAmount: .zero))
        XCTAssertThrowsError(try Budget(year: 2000, name: "Name", icon: .default, slices: []))
        XCTAssertThrowsError(try makeBudget(slices: [
            try makeSlice(name: "Name"),
            try makeSlice(name: "Name")
        ]))
    }

    func testInstantiateBudget_totalAmount_withSlices() throws {
        let budget = try Budget(year: 2000, name: "Name", icon: .default, slices: [
            BudgetSlice(name: "Name 1", configuration: .monthly(amount: .value(100))),
            BudgetSlice(name: "Name 2", configuration: .monthly(amount: .value(100))),
            BudgetSlice(name: "Name 3", configuration: .scheduled(schedules: [
                BudgetSlice.Schedule(amount: .value(100), month: 1),
                BudgetSlice.Schedule(amount: .value(150), month: 2)
            ]))
        ])

        let expectedAmount = MoneyValue.value(100*12 + 100*12 + 100 + 150)
        XCTAssertEqual(budget.amount, expectedAmount)
    }

    // MARK: Mutating

    func testUpdateBudgetName() throws {
        let name = "Name"
        var budget = try makeBudget(name: name)

        XCTAssertThrowsError(try budget.update(name: ""))
        XCTAssertNoThrow(try budget.update(name: name))
        XCTAssertNoThrow(try budget.update(name: "Any other name"))
    }

    func testUpdateBudget_appensSlice() throws {
        let slice1 = try makeSlice(name: "Name 1")
        let slice2 = try makeSlice(name: "Name 2")
        var budget = try makeBudget(slices: [slice1, slice2])

        // When: appending a slice with a different name
        // Then: no error thrown
        let slice3 = try makeSlice(name: "Name 3")
        XCTAssertNoThrow(try budget.append(slice: slice3))

        // When: appending a slice with the same name as others in the budget
        // Then: throw an error, becasue there can't be slices with the same name
        let slice4 = try makeSlice(name: slice3.name)
        XCTAssertThrowsError(try budget.append(slice: slice4))
    }

    func testUpdateBudget_deleteSlices() throws {
        let slice1 = try makeSlice(name: "Name 1")
        let slice2 = try makeSlice(name: "Name 2")
        var budget = try makeBudget(slices: [slice1, slice2])

        // When: deleting all slices
        // Then: throw an error, becasue there can't be a budget without slices
        var deletingIdentifiers = Set([slice1.id, slice2.id])
        XCTAssertThrowsError(try budget.delete(slicesWith: deletingIdentifiers))

        // When: deleting only one slice
        // Then: no errors are thrown
        deletingIdentifiers = [slice1.id]
        XCTAssertNoThrow(try budget.delete(slicesWith: deletingIdentifiers))

        // When: deleting the only one left slice
        // Then: throw an error, becasue there can't be a budget without slices
        deletingIdentifiers = [slice2.id]
        XCTAssertEqual(budget.slices.count, 1)
        XCTAssertThrowsError(try budget.delete(slicesWith: deletingIdentifiers))
    }

    // MARK: Getting

    func testGetAvailability() throws {
        let slice1 = try makeSlice(name: "Name 1", configuration: .monthly(amount: .value(100)))
        let slice2 = try makeSlice(name: "Name 2", configuration: .scheduled(schedules: [
            BudgetSlice.Schedule(amount: .value(100), month: 2),
            BudgetSlice.Schedule(amount: .value(100), month: 3),
            BudgetSlice.Schedule(amount: .value(100), month: 4)
        ]))
        let budget = try makeBudget(slices: [slice1, slice2])

        XCTAssertEqual(budget.availability(upTo: 1).value, 0)
        XCTAssertEqual(budget.availability(upTo: 2).value, 100)
        XCTAssertEqual(budget.availability(upTo: 3).value, 300)
        XCTAssertEqual(budget.availability(upTo: 4).value, 500)

        XCTAssertEqual(budget.availability(for: 1).value, 100)
        XCTAssertEqual(budget.availability(for: 2).value, 200)
        XCTAssertEqual(budget.availability(for: 3).value, 200)
        XCTAssertEqual(budget.availability(for: 4).value, 200)
    }

    func testGetSlicesAtIndices() throws {
        let slice1 = try makeSlice(name: "Name 1")
        let slice2 = try makeSlice(name: "Name 2")
        let budget = try makeBudget(slices: [slice1, slice2])

        XCTAssertTrue(budget.slices(at: IndexSet(integer: 0)).contains(slice1))
        XCTAssertTrue(budget.slices(at: IndexSet(integer: 1)).contains(slice2))
        XCTAssertEqual(budget.slices(at: IndexSet(0...1)), [slice1, slice2])
    }
}
