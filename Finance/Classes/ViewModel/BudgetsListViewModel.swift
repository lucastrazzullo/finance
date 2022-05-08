//
//  BudgetsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation
import Combine

final class BudgetsListViewModel: ObservableObject {

    typealias AddBudgetsHandler = () -> Void
    typealias DeleteBudgetsHandler = (Set<Budget.ID>) async throws -> Void

    @Published var budgets: [Budget]
    @Published var deleteBudgetError: DomainError?

    let addBudgets: AddBudgetsHandler
    let deleteBudgets: DeleteBudgetsHandler

    // MARK: Object life cycle

    init(budgets: [Budget], addBudgets: @escaping AddBudgetsHandler, deleteBudgets: @escaping DeleteBudgetsHandler) {
        self.budgets = budgets
        self.addBudgets = addBudgets
        self.deleteBudgets = deleteBudgets
    }

    // MARK: Internal methods

    func delete(budgetsAt offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await deleteBudgets(identifiersSet)
            budgets.delete(withIdentifiers: identifiersSet)
            deleteBudgetError = nil
        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}
