//
//  BudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetsListHandler: AnyObject {
    func add(budget: Budget) async throws
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws
}

@MainActor final class BudgetsListViewModel: ObservableObject {

    typealias Handler = BudgetsListHandler & BudgetHandler

    @Published var deleteBudgetError: DomainError?
    @Published var addNewBudgetIsPresented: Bool = false

    let year: Int
    let title: String
    let budgets: [Budget]

    private(set) weak var handler: Handler?

    init(year: Int, title: String, budgets: [Budget], handler: Handler?) {
        self.year = year
        self.title = title
        self.budgets = budgets
        self.handler = handler
    }

    // MARK: Internal methods

    func add(budget: Budget) async throws {
        try await handler?.add(budget: budget)
        addNewBudgetIsPresented = false
    }

    func delete(offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await handler?.delete(budgetsWith: identifiersSet)
            deleteBudgetError = nil
        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}
