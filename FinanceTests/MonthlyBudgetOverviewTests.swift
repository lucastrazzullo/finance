//
//  MonthlyBudgetOverviewTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import XCTest
@testable import Finance

final class MonthlyBudgetOverviewTests: XCTestCase {

    func testRemainingAmount() {
        var overview = makeOverview(startingAmount: 100, expenses: 25)
        XCTAssertEqual(overview.remainingAmount, .value(75))

        overview = makeOverview(startingAmount: 0, expenses: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-100))

        overview = makeOverview(startingAmount: -100, expenses: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-200))
    }

    func testRemainingAmountPercentage() {
        var overview = makeOverview(startingAmount: 100, expenses: 25)
        XCTAssertEqual(overview.remainingAmountPercentage, 0.75)

        overview = makeOverview(startingAmount: 0, expenses: 100)
        XCTAssertEqual(overview.remainingAmountPercentage, 0)

        overview = makeOverview(startingAmount: -100, expenses: 100)
        XCTAssertEqual(overview.remainingAmountPercentage, 0)
    }

    // MARK: Private helper methods

    private func makeOverview(startingAmount: Decimal, expenses: Decimal) -> MonthlyBudgetOverview {
        MonthlyBudgetOverview(
            name: "Name",
            icon: .none,
            startingAmount: .value(startingAmount),
            totalExpenses: .value(expenses)
        )
    }
}
