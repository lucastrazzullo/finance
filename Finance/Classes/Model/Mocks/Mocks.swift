//
//  Mocks.swift
//  Finance
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import Foundation

enum Mocks {

    // MARK: - Year

    static let year: Int = 2022
    static let openingYearBalance: MoneyValue = .value(10000)

    // MARK: - Overview

    static let yearlyOverview: YearlyBudgetOverview = {
        return YearlyBudgetOverview(
            name: "Mock",
            year: Mocks.year,
            openingBalance: Mocks.openingYearBalance,
            budgets: Mocks.allBudgets,
            transactions: Mocks.allTransactions
        )
    }()

    // MARK: - Budget

    static let allBudgets: [Budget] = {
        return incomeBudgets + expenseBudgets
    }()

    static let incomeBudgets: [Budget] = {
        return [
            try! .init(id: UUID(), year: year, kind: .income, name: "ING", icon: .default, slices: Mocks.ingSlices)
        ]
    }()

    static let expenseBudgets: [Budget] = {
        return [
            try! .init(id: UUID(), year: year, kind: .expense, name: "House", icon: .house, slices: Mocks.houseSlices),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Groceries", icon: .food, slices: Mocks.groceriesSlices),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Health", icon: .health, monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Luca", icon: .face2, monthlyAmount: .value(250.01)),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Travel", icon: .travel, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Ilenia", icon: .face, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, kind: .expense, name: "Car", icon: .car, monthlyAmount: .value(1000.00)),
        ]
    }()

    // MARK: Slice

    static let allSlices: [BudgetSlice] = {
        groceriesSlices + houseSlices + ingSlices
    }()

    static let houseSlices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Mortgage", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Furnitures", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Works", configuration: .scheduled(schedules: sliceScheduledAmounts))
        ]
    }()

    static let groceriesSlices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Food", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Home", configuration: .monthly(amount: .value(120.23))),
        ]
    }()

    static let ingSlices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Salary", configuration: .monthly(amount: .value(1000)))
        ]
    }()

    static let sliceScheduledAmounts: [BudgetSlice.Schedule] = {
        [
            try! .init(amount: .value(100), month: 1),
            try! .init(amount: .value(200), month: 2),
            try! .init(amount: .value(300), month: 7)
        ]
    }()

    // MARK: Transactions

    static let allTransactions: [Transaction] = {
        return expenses + incomes
    }()

    static let expenses: [Transaction] = {
        let date = Date.with(year: year, month: 1)!
        return [
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetKind: expenseBudgets[0].kind, budgetIdentifier: expenseBudgets[0].id, sliceIdentifier: expenseBudgets[0].slices[0].id)
            ]),
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetKind: expenseBudgets[0].kind, budgetIdentifier: expenseBudgets[0].id, sliceIdentifier: expenseBudgets[0].slices[1].id)
            ]),
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetKind: expenseBudgets[0].kind, budgetIdentifier: expenseBudgets[0].id, sliceIdentifier: expenseBudgets[0].slices[2].id)
            ]),
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetKind: expenseBudgets[0].kind, budgetIdentifier: expenseBudgets[1].id, sliceIdentifier: expenseBudgets[1].slices[0].id)
            ]),
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetKind: expenseBudgets[0].kind, budgetIdentifier: expenseBudgets[1].id, sliceIdentifier: expenseBudgets[1].slices[1].id)
            ])
        ]
    }()

    static let incomes: [Transaction] = {
        let date = Date.with(year: year, month: 1)!
        return [
            try! Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(1000), budgetKind: .income, budgetIdentifier: incomeBudgets[0].id, sliceIdentifier: incomeBudgets[0].slices[0].id)
            ])
        ]
    }()
}
