//
//  Budgets.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

struct Budgets {

    private var list: [Budget]

    init(list: [Budget] = []) {
        self.list = list
    }

    // MARK: Getters

    func all() -> [Budget] {
        return list
    }

    func budget(with id: Budget.ID) -> Budget? {
        return list.first(where: { $0.id == id })
    }

    // MARK: Mutating methods

    mutating func add(budget: Budget) throws {
        guard !list.contains(where: { $0.name == budget.name }) else {
            throw DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))
        }
        list.append(budget)
    }

    mutating func remove(budget: Budget) throws {
        guard list.contains(where: { $0.id == budget.id }) else {
            throw DomainError.budgets(error: .budgetDoesntExist)
        }
        list.removeAll(where: { $0.id == budget.id })
    }
}
