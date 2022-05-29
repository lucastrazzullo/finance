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
        let date = Date.with(year: 2000, month: 1, day: 1)!

        let budget = try Budget(
            id: .init(),
            year: date.year,
            kind: .expense,
            name: "Name",
            icon: .default,
            monthlyAmount: .value(budgetAmount)
        )

        let expense = try! Transaction(
            id: .init(),
            description: nil,
            date: date,
            amounts: [
                .init(
                    amount: .value(expensesAmount),
                    budgetKind: .expense,
                    budgetIdentifier: budget.id,
                    sliceIdentifier: budget.slices[0].id
                )
            ]
        )

        return MonthlyBudgetOverview(
            month: 1,
            budget: budget,
            transactions: [expense]
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
