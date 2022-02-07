//
//  MockBudgetStorageProvider.swift
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
            try! Budget(id: UUID(), name: "House", slices: Mocks.slices),
            try! Budget(id: UUID(), name: "Groceries", amount: .value(200.01)),
            try! Budget(id: UUID(), name: "Health", amount: .value(200.01))
        ]
    }()

    static let slices: [BudgetSlice] = {
        [
            try! BudgetSlice(id: .init(), name: "Mortgage", amount: .value(120.23)),
            try! BudgetSlice(id: .init(), name: "Furnitures", amount: .value(120.23))
        ]
    }()

    // MARK: - Transactions

    static let incomingTransactions: [Transaction] = {
        budgets
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(transfer: .income(amount: .value(100.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .income(amount: .value(200.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .income(amount: .value(300.02)), budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()

    static let outgoingTransactions: [Transaction] = {
        budgets
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(transfer: .expense(amount: .value(100.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .expense(amount: .value(200.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .expense(amount: .value(300.02)), budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()
}

final class MockBudgetStorageProvider: ReportStorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var budgets: [Budget] = Mocks.budgets

    // MARK: Budget list

    func fetchReport() async throws -> Report {
        return Report(budgets: budgets)
    }

    func add(budget: Budget) async throws -> Report {
        budgets.append(budget)
        return Report(budgets: budgets)
    }

    func delete(budget: Budget) async throws -> Report {
        budgets.removeAll(where: { $0.id == budget.id })
        return Report(budgets: budgets)
    }

    func delete(budgets: [Budget]) async throws -> Report {
        budgets.forEach { budget in
            self.budgets.removeAll(where: { $0.id == budget.id })
        }
        return Report(budgets: budgets)
    }

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID) async throws -> Budget {
        if let budget = budgets.first(where: { $0.id == identifier }) {
            return budget
        } else {
            throw DomainError.budgetProvider(error: .budgetEntityNotFound)
        }
    }

    func updateBudget(budget: Budget) async throws -> Budget {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budget.id }) else {
            throw DomainError.budgetProvider(error: .underlying(error: Error.mock))
        }

        budgets.remove(at: budgetIndex)
        budgets.insert(budget, at: budgetIndex)

        return budget
    }
}
#endif
