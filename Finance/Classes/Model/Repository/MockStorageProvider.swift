//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

#if DEBUG
enum Mocks {

    // MARK: - Overviews

    static let monthlyOverviews: [MonthlyBudgetOverview] = {
        [
            .init(
                name: "Ilenia",
                icon: .system(name: "face.dashed.fill"),
                startingAmount: .value(1200),
                totalExpenses: .value(300)
            ),
            .init(
                name: "Groceries",
                icon: .system(name: "fork.knife"),
                startingAmount: .value(800),
                totalExpenses: .value(700)
            ),
            .init(
                name: "Car",
                icon: .system(name: "bolt.car"),
                startingAmount: .value(800),
                totalExpenses: .value(1000)
            ),
            .init(
                name: "Health",
                icon: .system(name: "leaf"),
                startingAmount: .value(1000),
                totalExpenses: .value(500)
            )
        ]
    }()

    static let montlyExpiringOverviews: [MonthlyBudgetOverview] = {
        [
            .init(
                name: "Luca",
                icon: .system(name: "face.smiling.fill"),
                startingAmount: .value(1200),
                totalExpenses: .value(1000)
            ),
            .init(
                name: "Travel",
                icon: .system(name: "airplane"),
                startingAmount: .value(800),
                totalExpenses: .value(700)
            )
        ]
    }()

    // MARK: - Budgets

    static func budgets(withYear year: Int) -> [Budget] {
        [
            try! .init(id: UUID(), year: 2022, name: "House", slices: Mocks.slices),
            try! .init(id: UUID(), year: 2022, name: "Groceries", monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: 2022, name: "Health", monthlyAmount: .value(200.01))
        ]
    }

    static let slices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Mortgage", configuration: .montly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Furnitures", configuration: .montly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Works", configuration: .scheduled(schedules: sliceScheduledAmounts))
        ]
    }()

    static let sliceScheduledAmounts: [BudgetSlice.Schedule] = {
        [
            .init(amount: .value(100), month: Months.default[0]!),
            .init(amount: .value(200), month: Months.default[2]!),
            .init(amount: .value(300), month: Months.default[7]!)
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

    func update(name: String, inBudgetWith id: Budget.ID) async throws {
        guard let overviewIndex = budgetOverviews.firstIndex(where: { $0.budgetIdentifiers().contains(id) }) else {
            throw DomainError.storageProvider(error: .overviewEntityNotFound)
        }
        guard var budget = budgetOverviews[overviewIndex].budget(with: id) else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }

        try budget.update(name: name)

        budgetOverviews[overviewIndex].delete(budgetWith: id)
        try budgetOverviews[overviewIndex].append(budget: budget)
    }
}
#endif
