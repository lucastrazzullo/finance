//
//  BudgetsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation
import Combine

protocol BudgetsListDataProvider: AnyObject {
    func add(budget: Budget) async throws
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws
}

final class BudgetsListViewModel: ObservableObject {

    @Published var budgets: [Budget]
    @Published var deleteBudgetError: DomainError?

    private let dataProvider: BudgetsListDataProvider

    // MARK: Object life cycle

    init(budgets: [Budget], dataProvider: BudgetsListDataProvider) {
        self.dataProvider = dataProvider
        self.budgets = budgets
    }

    // MARK: Internal methods

    func add(budget: Budget) async throws {
        try await dataProvider.add(budget: budget)
        budgets.append(budget)
    }

    func delete(budgetsAt offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await dataProvider.delete(budgetsWith: identifiersSet)
            budgets.delete(withIdentifiers: identifiersSet)
            deleteBudgetError = nil
        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}
