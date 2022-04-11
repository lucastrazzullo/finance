//
//  YearlyBudgetOverviewTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import XCTest
@testable import Finance

final class YearlyBudgetOverviewTests: XCTestCase {

    // MARK: Instantiating

    func testInstantiateOverview_withValidData() throws {
        XCTAssertNoThrow(try YearlyBudgetOverview(name: "Name", year: 2000, budgets: [], transactions: []))

        let slice = try BudgetSlice(name: "Name", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(year: 2000, name: "Name", icon: .none, slices: [slice])
        let transaction = makeTransaction(date: "2000-02-02", budgetSliceId: slice.id, amount: .value(100))
        XCTAssertNoThrow(try YearlyBudgetOverview(name: "Name", year: 2000, budgets: [budget], transactions: [transaction]))
    }

    func testInstantiateOverview_withInvalidData() throws {
        XCTAssertThrowsError(try YearlyBudgetOverview(name: "", year: 2000, budgets: [], transactions: []))

        // Throws when instantiating with budget that has a different year than the overview
        let slice = try BudgetSlice(name: "Name", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(year: 2001, name: "Name", icon: .none, slices: [slice])
        XCTAssertThrowsError(try YearlyBudgetOverview(name: "Name", year: 2000, budgets: [budget], transactions: []))

        // Throws when instantiating with transaction that has slice id not present in budget's slices
        var transaction = makeTransaction(date: "2001-02-02", budgetSliceId: .init(), amount: .value(100))
        XCTAssertThrowsError(try YearlyBudgetOverview(name: "Name", year: 2001, budgets: [budget], transactions: [transaction]))

        // Throws when instantiating with transaction thah has year different than overview
        transaction = makeTransaction(date: "2000-02-02", budgetSliceId: slice.id, amount: .value(100))
        XCTAssertThrowsError(try YearlyBudgetOverview(name: "Name", year: 2001, budgets: [budget], transactions: [transaction]))
    }

    // MARK: Getting

    func testGetMonthlyOverview_forGivenBudget_andMonth() throws {
        let slice = try BudgetSlice(name: "Monthly", configuration: .monthly(amount: .value(100)))
        let budget = try Budget(year: 2000, name: "Name", icon: .none, slices: [slice])

        let transaction1 = makeTransaction(date: "2000-01-02", budgetSliceId: slice.id, amount: .value(50))
        let transaction2 = makeTransaction(date: "2000-02-02", budgetSliceId: slice.id, amount: .value(50))

        let yearlyOverview = try YearlyBudgetOverview(name: "Overview", year: 2000, budgets: [budget], transactions: [transaction1, transaction2])

        // Assert

        // Month: 01
        // Budget: 100 per month
        // Starting amount: 100 budget - 0 transactions in months before >> 100
        // Remaining amount: 100 starting amount - 50 transaction in month 01 >> 50

        let montlyOverview_month1 = try XCTUnwrap(yearlyOverview.monthlyOverview(month: 1, forBudgetWith: budget.id))
        XCTAssertEqual(montlyOverview_month1.startingAmount, .value(100))
        XCTAssertEqual(montlyOverview_month1.remainingAmount, .value(50))


        // Month: 02
        // Budget: 100 per month
        // Starting amount: 200 budget - 50 transactions in months before >> 150
        // Remaining amount: 150 starting amount - 50 transaction in month 02 >> 100

        let montlyOverview_month2 = try XCTUnwrap(yearlyOverview.monthlyOverview(month: 2, forBudgetWith: budget.id))
        XCTAssertEqual(montlyOverview_month2.startingAmount, .value(150))
        XCTAssertEqual(montlyOverview_month2.remainingAmount, .value(100))


        // Month: 03
        // Budget: 100 per month
        // Starting amount: 300 budget - 100 transactions in months before >> 200
        // Remaining amount: 200 starting amount - 0 transaction in month 02 >> 200

        let montlyOverview_month3 = try XCTUnwrap(yearlyOverview.monthlyOverview(month: 3, forBudgetWith: budget.id))
        XCTAssertEqual(montlyOverview_month3.startingAmount, .value(200))
        XCTAssertEqual(montlyOverview_month3.remainingAmount, .value(200))
    }

    // MARK: Private factory methods

    private func makeTransaction(date: String, budgetSliceId: BudgetSlice.ID, amount: MoneyValue) -> Transaction {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let date = dateFormatter.date(from: date)!
        return Transaction(description: nil, amount: amount, date: date, budgetSliceId: budgetSliceId)
    }
}
