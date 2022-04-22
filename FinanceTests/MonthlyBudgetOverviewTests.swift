//
//  MonthlyBudgetOverviewTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import XCTest
@testable import Finance

final class MonthlyBudgetOverviewTests: XCTestCase {

    // MARK: Factories

    private func makeOverview(budgetAmount: Decimal, expensesAmount: Decimal) throws -> MonthlyBudgetOverview {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        let date = Calendar.current.date(from: components)!

        let budget = try Budget(
            year: date.year,
            name: "Name",
            icon: .default,
            monthlyAmount: .value(budgetAmount)
        )

        let expense = Transaction(
            description: nil,
            amount: .value(expensesAmount),
            date: date,
            budgetSliceId: budget.slices[0].id
        )

        return MonthlyBudgetOverview(
            month: 1,
            expenses: [expense],
            budget: budget
        )
    }

    // MARK: Tests

    func testRemainingAmount() throws {
        var overview = try makeOverview(budgetAmount: 100, expensesAmount: 25)
        XCTAssertEqual(overview.remainingAmount, .value(75))

        overview = try makeOverview(budgetAmount: 10, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-90))

        overview = try makeOverview(budgetAmount: -100, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-200))
    }

    func testRemainingAmountPercentage() throws {
        var overview = try makeOverview(budgetAmount: 100, expensesAmount: 25)
        XCTAssertEqual(overview.remainingAmountPercentage, 0.75)

        overview = try makeOverview(budgetAmount: 10, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmountPercentage, 0)

        overview = try makeOverview(budgetAmount: -100, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmountPercentage, 0)
    }
}
