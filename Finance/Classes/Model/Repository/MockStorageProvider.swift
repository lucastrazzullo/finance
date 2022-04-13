//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

enum Mocks {

    static let year: Int = 2022

    // MARK: - Overview

    static let overview: YearlyBudgetOverview = {
        try! YearlyBudgetOverview(name: "Amsterdam", year: year, budgets: Mocks.budgets, transactions: Mocks.transactions)
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
        [
            try! .init(id: UUID(), year: year, name: "House", icon: .system(name: "house"), slices: Mocks.slices),
            try! .init(id: UUID(), year: year, name: "Groceries", icon: .system(name: "fork.knife"), monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: year, name: "Health", icon: .system(name: "leaf"), monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: year, name: "Luca", icon: .system(name: "face.smiling.fill"), monthlyAmount: .value(250.01)),
            try! .init(id: UUID(), year: year, name: "Travel", icon: .system(name: "airplane"), monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Ilenia", icon: .system(name: "face.dashed.fill"), monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Groceries", icon: .system(name: "fork.knife"), monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Car", icon: .system(name: "bolt.car"), monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Health", icon: .system(name: "leaf"), monthlyAmount: .value(1000.00))
        ]
    }()

    // MARK: Slice

    static let slices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Mortgage", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Furnitures", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Works", configuration: .scheduled(schedules: sliceScheduledAmounts))
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
        [
            Transaction(description: nil, amount: .value(100), date: .now, budgetSliceId: slices[0].id),
            Transaction(description: nil, amount: .value(100), date: .now, budgetSliceId: slices[1].id),
            Transaction(description: nil, amount: .value(1000), date: .now, budgetSliceId: slices[2].id)
        ]
    }()
}

final class MockStorageProvider: StorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var overview: YearlyBudgetOverview

    // MARK: Object life cycle

    init(budgets: [Budget] = [], transactions: [Transaction] = []) throws {
        let year = budgets.first?.year ?? Mocks.year
        self.overview = try YearlyBudgetOverview(
            name: "Mock Overview",
            year: year,
            budgets: budgets,
            transactions: transactions
        )
    }

    // MARK: Fetch

    func fetchYearlyOverview(year: Int) async throws -> YearlyBudgetOverview {
        guard overview.year == year else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        return overview
    }

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        let budgetList = BudgetList(budgets: overview.budgets)
        guard let budget = budgetList.budget(with: identifier) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
        return budget
    }

    // MARK: Add

    func add(budget: Budget) async throws {
        let budgetList = BudgetList(budgets: overview.budgets)
        try budgetList.willAdd(budget: budget)
        overview.append(budget: budget)
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        let budgetList = BudgetList(budgets: overview.budgets)
        guard var budget = budgetList.budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        try budget.append(slice: slice)

        overview.delete(budgetsWithIdentifiers: [id])
        overview.append(budget: budget)
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID> {
        let budgetList = BudgetList(budgets: overview.budgets)
        let budgets = budgetList.budgets(with: identifiers)

        guard !budgets.isEmpty else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        overview.delete(budgetsWithIdentifiers: identifiers)
        return Set(budgets.map(\.id))
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws {
        let budgetList = BudgetList(budgets: overview.budgets)
        guard var budget = budgetList.budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        let indices = IndexSet(budget.slices.compactMap({ budget.slices.firstIndex(of: $0) }))
        try budget.delete(slicesAt: indices)

        overview.delete(budgetsWithIdentifiers: [id])
        overview.append(budget: budget)
    }

    // MARK: Update

    func update(name: String, iconSystemName: String?, inBudgetWith id: Budget.ID) async throws {
        let budgetList = BudgetList(budgets: overview.budgets)
        guard var budget = budgetList.budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        try budget.update(name: name)

        if let iconSystemName = iconSystemName {
            try budget.update(iconSystemName: iconSystemName)
        }

        overview.delete(budgetsWithIdentifiers: [id])
        overview.append(budget: budget)
    }
}
