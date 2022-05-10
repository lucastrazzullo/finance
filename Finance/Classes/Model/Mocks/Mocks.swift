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

    // MARK: - Overview

    static let yearlyOverview: YearlyBudgetOverview = {
        return YearlyBudgetOverview(
            name: "Mock",
            year: Mocks.year,
            budgets: Mocks.budgets,
            expenses: Mocks.transactions
        )
    }()

    // MARK: - Budget

    static func randomBudgetIdentifiers(count: Int) -> [Budget.ID] {
        let favouriteBudgetsIdentifiers: Set<Budget.ID> = Set(favouriteBudgetsIdentifiers)
        var budgets = budgets.map(\.id).shuffled()
        budgets.removeAll(where: { favouriteBudgetsIdentifiers.contains($0) })
        guard budgets.count > count else {
            return budgets
        }
        return Array(budgets[0..<count])
    }

    static let favouriteBudgetsIdentifiers: [Budget.ID] = {
        return [
            budgets.first(where: { $0.name == "Ilenia" })?.id,
            budgets.first(where: { $0.name == "Groceries" })?.id,
            budgets.first(where: { $0.name == "Car" })?.id,
            budgets.first(where: { $0.name == "Health" })?.id
        ].compactMap({$0})
    }()

    static let budgets: [Budget] = {
        return [
            try! .init(id: UUID(), year: year, name: "House", icon: .house, slices: Mocks.houseSlices),
            try! .init(id: UUID(), year: year, name: "Groceries", icon: .food, slices: Mocks.groceriesSlices),
            try! .init(id: UUID(), year: year, name: "Health", icon: .health, monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: year, name: "Luca", icon: .face2, monthlyAmount: .value(250.01)),
            try! .init(id: UUID(), year: year, name: "Travel", icon: .travel, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Ilenia", icon: .face, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Car", icon: .car, monthlyAmount: .value(1000.00)),
        ]
    }()

    // MARK: Slice

    static let allSlices: [BudgetSlice] = {
        groceriesSlices + houseSlices
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

    static let sliceScheduledAmounts: [BudgetSlice.Schedule] = {
        [
            try! .init(amount: .value(100), month: 1),
            try! .init(amount: .value(200), month: 2),
            try! .init(amount: .value(300), month: 7)
        ]
    }()

    static let transactions: [Transaction] = {
        var components = DateComponents()
        components.year = year
        components.month = 1
        let date = Calendar.current.date(from: components)!
        return [
            Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetIdentifier: budgets[0].id, sliceIdentifier: budgets[0].slices[0].id)
            ]),
            Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetIdentifier: budgets[0].id, sliceIdentifier: budgets[0].slices[1].id)
            ]),
            Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetIdentifier: budgets[0].id, sliceIdentifier: budgets[0].slices[2].id)
            ]),
            Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetIdentifier: budgets[1].id, sliceIdentifier: budgets[1].slices[0].id)
            ]),
            Transaction(id: .init(), description: nil, date: date, amounts: [
                .init(amount: .value(100), budgetIdentifier: budgets[1].id, sliceIdentifier: budgets[1].slices[1].id)
            ])
        ]
    }()
}
