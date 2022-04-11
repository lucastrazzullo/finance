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
        let overview = MonthlyBudgetOverview(
            name: "Name",
            icon: .none,
            startingAmount: .value(100),
            totalExpenses: .value(25)
        )

        XCTAssertEqual(overview.remainingAmount, .value(75))
        XCTAssertEqual(overview.remainingAmountPercentage, 0.75)
    }
}
