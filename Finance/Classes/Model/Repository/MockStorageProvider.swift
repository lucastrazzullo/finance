//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

enum Mocks {

    static let year: Int = 2022

    static let overview: YearlyBudgetOverview = {
        try! YearlyBudgetOverview(name: "Amsterdam", year: year, budgets: Mocks.budgets)
    }()

    // MARK: - Budgets

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

    static let slices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Mortgage", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Furnitures", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Works", configuration: .scheduled(schedules: sliceScheduledAmounts))
        ]
    }()

    static let sliceScheduledAmounts: [BudgetSlice.Schedule] = {
        [
            .init(amount: .value(100), month: 0),
            .init(amount: .value(200), month: 2),
            .init(amount: .value(300), month: 7)
        ]
    }()
}

final class MockStorageProvider: StorageProvider, ObservableObject {

    private enum Error: Swift.Error {
        case mock
    }

    private var budgetOverviews: [YearlyBudgetOverview]

    // MARK: Object life cycle

    init(budgets: [Budget]) {
        let years = Set(budgets.map(\.year))
        let sortedYears = years.sorted(by: { $0 < $1 })
        self.budgetOverviews = sortedYears.map { year in
            try! YearlyBudgetOverview(id: .init(), name: "Mock Overview", year: year, budgets: budgets)
        }
    }

    init(overviewYear: Int) {
        self.budgetOverviews = [
            try! YearlyBudgetOverview(id: .init(), name: "Mock Overview", year: overviewYear, budgets: [])
        ]
    }

    // MARK: Fetch

    func fetchYearlyOverview(year: Int) async throws -> YearlyBudgetOverview {
        guard let overview = budgetOverviews.first(where: { $0.year == year }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        return overview
    }

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        guard let overview = budgetOverviews.first(where: { $0.budgetIdentifiers().contains(identifier) }),
              let budget = overview.budget(with: identifier) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
        return budget
    }

    // MARK: Add

    func add(budget: Budget) async throws {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { $0.year == budget.year }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }

        try budgetOverviews[overviewIndex].append(budget: budget)
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { $0.budgetIdentifiers().contains(id) }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        guard var budget = budgetOverviews[overviewIndex].budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        try budget.append(slice: slice)

        budgetOverviews[overviewIndex].delete(budgetWith: budget.id)
        try budgetOverviews[overviewIndex].append(budget: budget)
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID> {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { identifiers.isSubset(of: $0.budgetIdentifiers()) }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        let budgets = budgetOverviews[overviewIndex].budgets(with: identifiers)
        budgetOverviews[overviewIndex].delete(budgetsWith: identifiers)
        return Set(budgets.map(\.id))
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { $0.budgetIdentifiers().contains(id) }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        guard var budget = budgetOverviews[overviewIndex].budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        let indices = IndexSet(budget.slices.compactMap({ budget.slices.firstIndex(of: $0) }))
        try budget.delete(slicesAt: indices)

        budgetOverviews[overviewIndex].delete(budgetWith: budget.id)
        try budgetOverviews[overviewIndex].append(budget: budget)
    }

    // MARK: Update

    func update(name: String, iconSystemName: String?, inBudgetWith id: Budget.ID) async throws {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { $0.budgetIdentifiers().contains(id) }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        guard var budget = budgetOverviews[overviewIndex].budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        try budget.update(name: name)

        if let iconSystemName = iconSystemName {
            try budget.update(iconSystemName: iconSystemName)
        }

        budgetOverviews[overviewIndex].delete(budgetWith: id)
        try budgetOverviews[overviewIndex].append(budget: budget)
    }
}
