//
//  Budgets.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

struct Budgets {

    let list: [Budget]

    init(list: [Budget] = []) {
        self.list = list
    }

    func canAdd(budget: Budget) throws {
        guard !list.contains(where: { $0.name == budget.name }) else {
            throw DomainError.budgets(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }

    func canRemove(budget: Budget) throws {
        guard list.contains(where: { $0.id == budget.id }) else {
            throw DomainError.budgets(error: .budgetDoesntExist)
        }
    }
}
