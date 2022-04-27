//
//  MockBudgetsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import Foundation

final class MockBudgetsListDataProvider: BudgetsListDataProvider {

    var year: Int = Mocks.year
    var budgets: [Budget]

    init(budgets: [Budget]) {
        self.budgets = budgets
    }

    func add(budget: Budget) async throws {
        budgets.append(budget)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        identifiers.forEach { identifier in
            budgets.removeAll(where: { $0.id == identifier })
        }
    }
}
