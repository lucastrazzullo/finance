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

    private func makeOverview(startingAmount: Decimal, expensesAmount: Decimal) throws -> BudgetOverview {
        let date = Date.with(year: 2000, month: 1, day: 1)!

        let budget = try Budget(
            id: .init(),
            year: date.year,
            kind: .expense,
            name: "Name",
            icon: .default,
            monthlyAmount: .value(abs(startingAmount))
        )

        let startingExpense = try! Transaction(
            id: .init(),
            description: nil,
            date: date,
            amounts: [
                .init(
                    amount: .value(startingAmount < 0 ? abs(startingAmount) * 2 : 0),
                    budgetKind: .expense,
                    budgetIdentifier: budget.id,
                    sliceIdentifier: budget.slices[0].id
                )
            ]
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

        return BudgetOverview(
            month: 1,
            budget: budget,
            transactions: [startingExpense, expense]
        )
    }

    // MARK: Tests

    func testRemainingAmount() throws {
        var overview = try makeOverview(startingAmount: 100, expensesAmount: 25)
        XCTAssertEqual(overview.remainingAmount, .value(75))

        overview = try makeOverview(startingAmount: 10, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-90))

        overview = try makeOverview(startingAmount: -100, expensesAmount: 100)
        XCTAssertEqual(overview.remainingAmount, .value(-200))
    }

    func testRemainingAmountPercentage() throws {
        var overview = try makeOverview(startingAmount: 100, expensesAmount: 25)
        XCTAssertEqual(overview.amountPercentage, 0.75)

        overview = try makeOverview(startingAmount: 10, expensesAmount: 100)
        XCTAssertEqual(overview.amountPercentage, -9.0)

        overview = try makeOverview(startingAmount: -100, expensesAmount: 100)
        XCTAssertEqual(overview.amountPercentage, -2.0)
    }
}
