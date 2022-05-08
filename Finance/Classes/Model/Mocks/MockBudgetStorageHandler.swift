//
//  MockBudgetStorageHandler.swift
//  Finance
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import Foundation

final class MockBudgetStorageHandler: BudgetStorageHandler {

    enum MockError: Error {
        case budgetNotFound
    }

    private var budgets: [Budget]

    init(budgets: [Budget]) {
        self.budgets = budgets
    }

    func budget(with identifier: Budget.ID) async throws -> Budget {
        guard let budget = budgets.with(identifier: identifier) else {
            throw MockError.budgetNotFound
        }
        return budget
    }

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        guard let index = budgets.firstIndex(where: { $0.id == identifier }) else {
            throw MockError.budgetNotFound
        }
        try budgets[index].append(slice: slice)
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        guard let index = budgets.firstIndex(where: { $0.id == identifier }) else {
            throw MockError.budgetNotFound
        }
        try budgets[index].delete(slicesWith: identifiers)
    }

    func update(name: String, icon: SystemIcon, in budget: Budget) async throws {
        guard let index = budgets.firstIndex(where: { $0.id == budget.id }) else {
            throw MockError.budgetNotFound
        }
        try budgets[index].update(name: name)
        try budgets[index].update(icon: icon)
    }
}
