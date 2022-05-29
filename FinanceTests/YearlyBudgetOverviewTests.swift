//
//  YearlyBudgetOverviewTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import XCTest
@testable import Finance

final class YearlyBudgetOverviewTests: XCTestCase {

    // MARK: Factories

    private func makeOverview(year: Int, budgets: [Budget], expenses: [Transaction]) throws -> YearlyBudgetOverview {
        return YearlyBudgetOverview(name: "Name", year: year, budgets: budgets, expenses: expenses)
    }

    private func makeBudget(year: Int, name: String = "Name", slices: [BudgetSlice]? = nil) throws -> Budget {
        let slices = try (slices ?? [try makeSlice()])
        return try Budget(id: .init(), year: year, name: name, icon: .default, slices: slices)
    }

    private func makeSlice() throws -> BudgetSlice {
        return try BudgetSlice(id: .init(), name: "Name", configuration: .monthly(amount: .value(100)))
    }

    private func makeTransaction(year: Int, month: Int = 1, budgetId: Budget.ID = .init(), budgetSliceId: BudgetSlice.ID = .init(), amount: MoneyValue = .value(100)) -> Transaction {
        let date = Date.with(year: year, month: month, day: 1)!
        return Transaction(id: .init(), description: nil, date: date, amounts: [.init(amount: amount, budgetIdentifier: budgetId, sliceIdentifier: budgetSliceId)])
    }

    // MARK: Instantiating

    func testInstantiateOverview() throws {
        let slice = try makeSlice()
        let budget = try makeBudget(year: 2000, slices: [slice])
        let expense = makeTransaction(year: 2000, month: 1, budgetId: budget.id, budgetSliceId: slice.id)
        let overview = try makeOverview(year: 2000, budgets: [budget], expenses: [expense])

        XCTAssertEqual(overview.budgets, [budget])
        XCTAssertEqual(overview.expenses, [expense])
    }

    func testInstantiateOverview_withDifferentYear() throws {
        let slice = try makeSlice()
        let budget = try makeBudget(year: 2000, slices: [slice])
        let expense = makeTransaction(year: 2000, month: 1, budgetId: budget.id, budgetSliceId: slice.id)
        let overview = try makeOverview(year: 1999, budgets: [budget], expenses: [expense])

        XCTAssertTrue(overview.budgets.isEmpty)
        XCTAssertTrue(overview.expenses.isEmpty)
    }

    // MARK: Mutating

    func testSetBudgetsAndTransactions_withSameYear() throws {
        var overview = try makeOverview(year: 2000, budgets: [], expenses: [])

        let slice = try makeSlice()
        let budget = try makeBudget(year: overview.year, slices: [slice])
        let expense = makeTransaction(year: overview.year, month: 1, budgetId: budget.id, budgetSliceId: slice.id)

        overview.set(budgets: [budget])
        overview.set(expenses: [expense])

        XCTAssertEqual(overview.budgets, [budget])
        XCTAssertEqual(overview.expenses, [expense])
    }

    func testSetBudgetsAndTransactions_withDifferentYear() throws {
        var overview = try makeOverview(year: 2000, budgets: [], expenses: [])

        let slice = try makeSlice()
        let budget = try makeBudget(year: 1999, slices: [slice])
        let expense = makeTransaction(year: 1999, month: 1, budgetId: budget.id, budgetSliceId: slice.id)

        overview.set(budgets: [budget])
        overview.set(expenses: [expense])

        XCTAssertEqual(overview.budgets, [])
        XCTAssertEqual(overview.expenses, [])
    }

    func testAppendBudget() throws {
        var overview = try makeOverview(year: 2000, budgets: [], expenses: [])

        // Budget with same year
        var budget = try makeBudget(year: overview.year, name: "Name")
        XCTAssertNoThrow(try overview.append(budget: budget))

        // Budget with same name
        budget = try makeBudget(year: overview.year, name: "Name")
        XCTAssertThrowsError(try overview.append(budget: budget))

        // Budget with different year
        budget = try makeBudget(year: 1999, name: "Different name")
        XCTAssertThrowsError(try overview.append(budget: budget))
    }

    func testAppendTransaction() throws {
        var overview = try makeOverview(year: 2000, budgets: [], expenses: [])

        // Transaction with same year
        var transaction = makeTransaction(year: overview.year)
        XCTAssertNoThrow(try overview.append(expenses: [transaction]))

        // Transaction with different year
        transaction = makeTransaction(year: 1999)
        XCTAssertThrowsError(try overview.append(expenses: [transaction]))
    }

    // MARK: Getting

    func testGetMonthlyOverview_forGivenBudget_andMonth() throws {
        let slice = try BudgetSlice(id: .init(), name: "Monthly", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(id: .init(), year: 2000, name: "Name", icon: .default, slices: [slice])

        let transaction1 = makeTransaction(year: 2000, month: 1, budgetId: budget.id, budgetSliceId: slice.id, amount: .value(50))
        let transaction2 = makeTransaction(year: 2000, month: 2, budgetId: budget.id, budgetSliceId: slice.id, amount: .value(50))

        let yearlyOverview = YearlyBudgetOverview(name: "Name", year: 2000, budgets: [budget], expenses: [transaction1, transaction2])

        // Assert

        // Month: 01
        // Budget: 100 per month
        // Starting amount: 100 budget - 0 transactions in months before >> 100
        // Remaining amount: 100 starting amount - 50 transaction in month 01 >> 50

        let montlyOverview_month1 = try XCTUnwrap(yearlyOverview.monthlyOverviews(month: 1).first { $0.name == budget.name })
        XCTAssertEqual(montlyOverview_month1.startingAmount, .value(100))
        XCTAssertEqual(montlyOverview_month1.remainingAmount, .value(50))


        // Month: 02
        // Budget: 100 per month
        // Starting amount: 200 budget - 50 transactions in months before >> 150
        // Remaining amount: 150 starting amount - 50 transaction in month 02 >> 100

        let montlyOverview_month2 = try XCTUnwrap(yearlyOverview.monthlyOverviews(month: 2).first { $0.name == budget.name })
        XCTAssertEqual(montlyOverview_month2.startingAmount, .value(150))
        XCTAssertEqual(montlyOverview_month2.remainingAmount, .value(100))


        // Month: 03
        // Budget: 100 per month
        // Starting amount: 300 budget - 100 transactions in months before >> 200
        // Remaining amount: 200 starting amount - 0 transaction in month 02 >> 200

        let montlyOverview_month3 = try XCTUnwrap(yearlyOverview.monthlyOverviews(month: 3).first { $0.name == budget.name })
        XCTAssertEqual(montlyOverview_month3.startingAmount, .value(200))
        XCTAssertEqual(montlyOverview_month3.remainingAmount, .value(200))
    }

    func testGetMonthlyOverview_withUnownedTransactions() throws {
        let transaction1 = makeTransaction(year: 2000, month: 1, amount: .value(50))
        let transaction2 = makeTransaction(year: 2000, month: 1, amount: .value(50))
        let expenses = [transaction1, transaction2]
        let yearlyOverview = YearlyBudgetOverview(name: "Name", year: 2000, budgets: [], expenses: expenses)

        XCTAssertTrue(yearlyOverview.monthlyOverviews(month: 1).isEmpty)
    }

}
