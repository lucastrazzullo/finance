//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

#if DEBUG
enum Mocks {

    // MARK: - Budgets

    static let budgets: [Budget] = {
        [
            try! .init(id: UUID(), name: "House", slices: Mocks.slices),
            try! .init(id: UUID(), name: "Groceries", monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), name: "Health", monthlyAmount: .value(200.01))
        ]
    }()

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

    private var report: Report

    // MARK: Object life cycle

    init(budgets: [Budget] = Mocks.budgets) {
        self.report = try! Report(id: .init(), name: "Mock Report", budgets: budgets)
    }

    // MARK: Fetch

    func fetchReport() async throws -> Report {
        return report
    }

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        if let budget = report.budgets.first(where: { $0.id == identifier }) {
            return budget
        } else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
    }

    // MARK: Add

    func add(budget: Budget) async throws {
        try report.append(budget: budget)
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        if let budgetIndex = report.budgets.firstIndex(where: { $0.id == id }),
            var budget = report.budget(at: budgetIndex) {
            try budget.append(slice: slice)

            report.delete(budgetWith: budget.id)
            try report.append(budget: budget)

        } else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID> {
        let budgets = report.budgets(with: identifiers)
        report.delete(budgetsWith: identifiers)
        return Set(budgets.map(\.id))
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws {
        if var budget = report.budgets.first(where: { $0.id == id }) {
            let indices = IndexSet(budget.slices.compactMap({ budget.slices.firstIndex(of: $0) }))
            try budget.delete(slicesAt: indices)

            report.delete(budgetWith: budget.id)
            try report.append(budget: budget)
        } else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
    }
}
#endif
