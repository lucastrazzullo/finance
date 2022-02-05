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

final class MockBudgetStorageProvider: BudgetStorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var budgets: [Budget] = Mocks.budgets

    // MARK: Budget list

    func fetchBudgets(completion: @escaping BudgetProvider.BudgetListCompletion) {
        completion(.success(budgets))
    }

    func add(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion) {
        budgets.append(budget)
        completion(.success(budgets))
    }

    func delete(budget: Budget, completion: @escaping BudgetProvider.BudgetListCompletion) {
        budgets.removeAll(where: { $0.id == budget.id })
        completion(.success(budgets))
    }

    func delete(budgets: [Budget], completion: @escaping BudgetProvider.BudgetListCompletion) {
        budgets.forEach { budget in
            self.budgets.removeAll(where: { $0.id == budget.id })
        }
        completion(.success(budgets))
    }

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion) {
        if let budget = budgets.first(where: { $0.id == identifier }) {
            completion(.success(budget))
        } else {
            completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
        }
    }

    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }) else {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        let oldBudget = budgets.remove(at: budgetIndex)
        var slices = oldBudget.slices
        slices.append(budgetSlice)
        
        do {
            let newBudget = try Budget(id: oldBudget.id, name: oldBudget.name, slices: slices)
            budgets.insert(newBudget, at: budgetIndex)
            completion(.success(newBudget))
        } catch {
            budgets.insert(oldBudget, at: budgetIndex)
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }
    }

    func delete(budgetSlice: BudgetSlice, fromBudgetWith budgetId: Budget.ID, completion: @escaping BudgetProvider.BudgetCompletion) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.slices.contains(where: { $0.id == budgetSlice.id}) }) else {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        let oldBudget = budgets.remove(at: budgetIndex)
        var slices = oldBudget.slices
        slices.removeAll(where: { $0.id == budgetSlice.id })

        do {
            let newBudget = try Budget(id: oldBudget.id, name: oldBudget.name, slices: slices)
            budgets.insert(newBudget, at: budgetIndex)
            completion(.success(newBudget))
        } catch {
            budgets.insert(oldBudget, at: budgetIndex)
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }
    }
}
#endif
