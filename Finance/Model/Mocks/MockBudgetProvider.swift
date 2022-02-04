//
//  MockBudgetProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

final class MockBudgetProvider: BudgetProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var budgets: [Budget] = Mocks.budgets

    // MARK: Add

    func add(budget: Budget, completion: @escaping MutateCompletion) {
        budgets.append(budget)
        completion(.success(Void()))
    }

    func add(budgetSlice: BudgetSlice, toBudgetWith budgetId: Budget.ID, completion: @escaping MutateCompletion) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }) else {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        var budget = budgets.remove(at: budgetIndex)
        do {
            try budget.add(newSlice: budgetSlice)
            completion(.success(Void()))
        } catch {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        budgets.insert(budget, at: budgetIndex)
    }

    // MARK: Delete

    func delete(budget: Budget, completion: @escaping MutateCompletion) {
        budgets.removeAll(where: { $0.id == budget.id })
        completion(.success(Void()))
    }

    func delete(budgets: [Budget], completion: @escaping MutateCompletion) {
        budgets.forEach { budget in
            self.budgets.removeAll(where: { $0.id == budget.id })
        }
        completion(.success(Void()))
    }

    func delete(budgetSlice: BudgetSlice, completion: @escaping MutateCompletion) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.slices.contains(where: { $0.id == budgetSlice.id}) }) else {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        var budget = budgets.remove(at: budgetIndex)
        do {
            try budget.remove(slice: budgetSlice)
            completion(.success(Void()))
        } catch {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        budgets.insert(budget, at: budgetIndex)
    }

    // MARK: Update

    func update(budget: Budget, completion: @escaping MutateCompletion) {
        guard let budgetIndex = budgets.firstIndex(where: { $0.id == budget.id }) else {
            completion(.failure(.budgetProvider(error: .underlying(error: Error.mock))))
            return
        }

        budgets.remove(at: budgetIndex)
        budgets.insert(budget, at: budgetIndex)
        completion(.success(Void()))
    }

    // MARK: Fetch

    func fetchBudget(with identifier: Budget.ID, completion: @escaping FetchBudgetCompletion) {
        if let budget = budgets.first(where: { $0.id == identifier }) {
            completion(.success(budget))
        } else {
            completion(.failure(.budgetProvider(error: .budgetEntityNotFound)))
        }
    }

    func fetchBudgets(completion: @escaping FetchBudgetListCompletion) {
        completion(.success(budgets))
    }
}
