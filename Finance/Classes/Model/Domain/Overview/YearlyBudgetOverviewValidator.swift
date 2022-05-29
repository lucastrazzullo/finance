//
//  YearlyBudgetOverviewValidator.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import Foundation

enum YearlyBudgetOverviewValidator {

    static func willAdd(budget: Budget, to list: [Budget], year: Int) throws {
        guard budget.year == year else {
            throw DomainError.budgetOverview(error: .cannotAddBudget)
        }
        guard list.allSatisfy({ $0.year == budget.year }) else {
            throw DomainError.budgetOverview(error: .cannotAddBudget)
        }
        guard !list.contains(where: { $0.name == budget.name }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: budget.name))
        }
    }

    static func willUpdate(name: String, for budget: Budget, in list: [Budget]) throws {
        guard budget.name != name else {
            return
        }
        guard !list.contains(where: { $0.name == name }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: name))
        }
    }

    static func willAdd(transactions: [Transaction], for year: Int) throws {
        guard !transactions.contains(where: { $0.date.year != year }) else {
            throw DomainError.budgetOverview(error: .transactionsListNotValid)
        }
    }
}
