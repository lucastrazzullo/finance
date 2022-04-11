//
//  BudgetSliceTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import XCTest
@testable import Finance

class BudgetSliceTests: XCTestCase {

    // MARK: Instantiating

    func testInstantiateSlice_withValidData() {
        XCTAssertNotNil(try BudgetSlice(name: "Name", monthlyAmount: "100"))
        XCTAssertNotNil(try BudgetSlice(name: "Name", configuration: .monthly(amount: .value(100))))
        XCTAssertNotNil(try BudgetSlice(name: "Name", configuration: .scheduled(schedules: [.init(amount: .value(100), month: 1)])))
    }

    func testInstantiateSlice_withInvalidData() {
        XCTAssertThrowsError(try BudgetSlice(name: "Name", monthlyAmount: ""))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", monthlyAmount: "-"))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", monthlyAmount: "amount"))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", monthlyAmount: "0"))

        XCTAssertThrowsError(try BudgetSlice(name: "Name", configuration: .monthly(amount: .zero)))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", configuration: .scheduled(schedules: [])))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", configuration: .scheduled(schedules: [.init(amount: .zero, month: 1)])))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", configuration: .scheduled(schedules: [.init(amount: .value(100), month: 0)])))
        XCTAssertThrowsError(try BudgetSlice(name: "Name", configuration: .scheduled(schedules: [.init(amount: .value(100), month: 13)])))
    }

    // MARK: Mutating

    func testBudgetSliceWillAddSchedule() throws {
        let schedule1 = try BudgetSlice.Schedule(amount: .value(100), month: 1)
        let schedule2 = try BudgetSlice.Schedule(amount: .value(100), month: 2)

        try BudgetSlice.willAdd(schedule: schedule1, to: [])
        try BudgetSlice.willAdd(schedule: schedule2, to: [])

        XCTAssertThrowsError(try BudgetSlice.willAdd(schedule: schedule1, to: [schedule1, schedule2]))
    }

}
