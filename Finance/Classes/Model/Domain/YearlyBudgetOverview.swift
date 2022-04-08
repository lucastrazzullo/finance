//
//  YearlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct YearlyBudgetOverview: Identifiable {

    static func current(with budgets: [Budget]) -> YearlyBudgetOverview {
        try! YearlyBudgetOverview(id: .init(), name: "Amsterdam", year: 2022, budgets: budgets)
    }

    let id: UUID
    let name: String
    let year: Int
    private(set) var budgets: [Budget]

    // MARK: Object life cycle

    init(id: ID, name: String, year: Int, budgets: [Budget]) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetOverview(error: .nameNotValid)
        }
        self.id = id
        self.name = name
        self.year = year
        self.budgets = budgets
    }

    // MARK: Getter methods

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

    // MARK: Mutating methods

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

    func willUpdate(budgetName: String) throws {
        try willIntroduce(newBudgetName: budgetName)
    }

    private func willIntroduce(newBudgetName: String) throws {
        guard !budgets.contains(where: { $0.name == newBudgetName }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: newBudgetName))
        }
    }
}
