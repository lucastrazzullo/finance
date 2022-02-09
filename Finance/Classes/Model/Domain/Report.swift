//
//  Report.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct Report: Identifiable {

    let id: UUID
    let name: String
    let budgets: [Budget]

    // MARK: Object life cycle

    init(budgets: [Budget]) {
        try! self.init(id: .init(), name: "Budgets", budgets: budgets)
    }

    init(id: ID, name: String, budgets: [Budget]) throws {
        guard !name.isEmpty else {
            throw DomainError.report(error: .nameNotValid)
        }
        self.id = id
        self.name = name
        self.budgets = budgets
    }

    func budgets(at offsets: IndexSet) -> [Budget] {
        return offsets.compactMap { index -> Budget? in
            guard budgets.indices.contains(index) else {
                return nil
            }
            return budgets[index]
        }
    }

    func canAdd(budget: Budget) throws {
        try Self.canAdd(budget: budget, to: budgets)
    }

    func canUpdate(budget: Budget) throws {
        try Self.canUpdate(budget: budget, in: budgets)
    }

    static func canAdd(budget: Budget, to list: [Budget]) throws {
        guard !list.contains(where: { $0.name == budget.name }) else {
            throw DomainError.report(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }

    static func canUpdate(budget: Budget, in list: [Budget]) throws {
        guard !list.contains(where: { $0.id != budget.id && $0.name == budget.name }) else {
            throw DomainError.report(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }
}
