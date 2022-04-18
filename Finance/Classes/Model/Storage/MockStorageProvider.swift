//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

enum Mocks {

    // MARK: - Overview

    static let year: Int = YearlyBudgetOverview.defaultYear
    static let overview: YearlyBudgetOverview = {
        try! YearlyBudgetOverview(budgets: Mocks.budgets, transactions: Mocks.transactions)
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
        let date = Calendar.current.date(from: components)!
        return [
            Transaction(description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[0].id),
            Transaction(description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[1].id),
            Transaction(description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[2].id),
            Transaction(description: nil, amount: .value(1000), date: date, budgetSliceId: groceriesSlices[0].id),
            Transaction(description: nil, amount: .value(1000), date: date, budgetSliceId: groceriesSlices[1].id)
        ]
    }()
}

final class MockStorageProvider: StorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var overview: YearlyBudgetOverview

    // MARK: Object life cycle

    init() {
        self.overview = YearlyBudgetOverview.empty
    }

    init(budgets: [Budget], transactions: [Transaction]) throws {
        self.overview = try YearlyBudgetOverview(budgets: budgets, transactions: transactions)
    }

    // MARK: Fetch

    func fetchBudgets(year: Int) async throws -> [Budget] {
        guard overview.year == year else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        return overview.budgets
    }

    func fetchTransactions(year: Int) async throws -> [Transaction] {
        guard overview.year == year else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        return overview.transactions
    }

    // MARK: Add

    func add(transaction: Transaction) async throws {
        try overview.append(transactions: [transaction])
    }

    func add(budget: Budget) async throws {
        try overview.append(budget: budget)
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        try overview.append(slice: slice, toBudgetWith: id)
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        overview.delete(budgetsWithIdentifiers: identifiers)
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        try overview.delete(slicesWith: identifiers, inBudgetWith: identifier)
    }

    // MARK: Update

    func update(name: String, iconSystemName: String, inBudgetWith id: Budget.ID) async throws {
        guard let icon = SystemIcon(rawValue: iconSystemName) else {
            throw DomainError.storageProvider(error: .cannotCreateBudgetWithEntity)
        }
        try overview.update(name: name, icon: icon, forBudgetWith: id)
    }
}
