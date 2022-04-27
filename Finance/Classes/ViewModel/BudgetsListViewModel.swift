//
//  BudgetsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetsListDataProvider: AnyObject {
    var year: Int { get }
    var budgets: [Budget] { get }

    func add(budget: Budget) async throws
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws
}

final class BudgetsListViewModel: ObservableObject {

    @Published var isAddNewBudgetPresented: Bool = false
    @Published var deleteBudgetError: DomainError?

    var year: Int { dataProvider.year }
    var budgets: [Budget] { dataProvider.budgets }

    private let dataProvider: BudgetsListDataProvider

    // MARK: Object life cycle

    init(dataProvider: BudgetsListDataProvider) {
        self.dataProvider = dataProvider
    }

    // MARK: Internal methods

    func add(budget: Budget) async throws {
        try await dataProvider.add(budget: budget)
        isAddNewBudgetPresented = false
    }

    func delete(budgetsAt offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await dataProvider.delete(budgetsWith: identifiersSet)
            deleteBudgetError = nil
        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}
