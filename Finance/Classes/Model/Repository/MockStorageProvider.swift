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

    static let sliceScheduledAmounts: [BudgetSlice.ScheduledAmount] = {
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

    private var budgets: [Budget]

    init(budgets: [Budget] = Mocks.budgets) {
        self.budgets = budgets
    }

    // MARK: Budget list

    func fetchReport() async throws -> Report {
        return Report(budgets: budgets)
    }

    // MARK: Budget

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        if let budget = budgets.first(where: { $0.id == identifier }) {
            return budget
        } else {
            throw DomainError.storageProvider(error: .budgetEntityNotFound)
        }
    }

    func delete(budgetWith identifier: Budget.ID) async throws -> Report {
        budgets.removeAll(where: { $0.id == identifier })
        return Report(budgets: budgets)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Report {
        self.budgets.removeAll(where: { identifiers.contains($0.id) })
        return Report(budgets: budgets)
    }

    func add(budget: Budget) async throws -> Report {
        budgets.append(budget)
        return Report(budgets: budgets)
    }

    func update(budget: Budget) async throws -> Budget {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budget.id }) else {
            throw DomainError.storageProvider(error: .underlying(error: Error.mock))
        }

        budgets.remove(at: budgetIndex)
        budgets.insert(budget, at: budgetIndex)

        return budget
    }
}
#endif
