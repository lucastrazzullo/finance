//
//  BudgetList.swift
//  Finance
//
//  Created by Luca Strazzullo on 12/04/2022.
//

import Foundation

struct BudgetList {

    private(set) var budgets: [Budget]

    // MARK: Getting

    func budget(with identifier: Budget.ID) -> Budget? {
        return budgets.first(where: { $0.id == identifier })
    }

    func budget(at index: Int) -> Budget? {
        guard budgets.indices.contains(index) else {
            return nil
        }
        return budgets[index]
    }

    func budgets(at indices: IndexSet) -> [Budget] {
        return budgets
            .enumerated()
            .filter { index, budget -> Bool in indices.contains(index) }
            .map(\.element)
    }

    func budgets(with identifiers: Set<Budget.ID>) -> [Budget] {
        return budgets.filter({ identifiers.contains($0.id) })
    }

    func budgetIdentifiers(at indices: IndexSet) -> Set<Budget.ID> {
        return Set(budgets(at: indices).map(\.id))
    }

    func budgetIdentifiers() -> Set<Budget.ID> {
        return Set(budgets.map(\.id))
    }

    // MARK: Mutating

    mutating func delete(budgetWith id: Budget.ID) {
        budgets.removeAll(where: { $0.id == id })
    }

    mutating func delete(budgetsWith identifiers: Set<Budget.ID>) {
        budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    mutating func append(budget: Budget) throws {
        try willAdd(budget: budget)
        budgets.append(budget)
    }

    // MARK: Helper methods

    func willAdd(budget: Budget) throws {
        try willIntroduce(newBudgetName: budget.name)
    }

    func willUpdate(budgetName: String, forBudgetWith id: Budget.ID) throws {
        guard budgets.contains(where: { $0.id == id && $0.name != budgetName }) else {
            return
        }
        try willIntroduce(newBudgetName: budgetName)
    }

    private func willIntroduce(newBudgetName: String) throws {
        guard !budgets.contains(where: { $0.name == newBudgetName }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: newBudgetName))
        }
    }
}
