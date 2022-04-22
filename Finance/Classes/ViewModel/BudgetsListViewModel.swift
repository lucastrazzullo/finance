//
//  BudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetsListViewModelDelegate: AnyObject {
    func willAdd(budget: Budget) throws
    func didAdd(budget: Budget) throws

    func didDelete(budgetsWith identifiers: Set<Budget.ID>)
}

@MainActor final class BudgetsListViewModel: ObservableObject {

    typealias Delegate = BudgetsListViewModelDelegate & BudgetViewModelDelegate

    @Published var deleteBudgetError: DomainError?
    @Published var addNewBudgetIsPresented: Bool = false

    @Published var budgets: [Budget]

    weak var delegate: Delegate?

    let year: Int
    let title: String

    private let storageProvider: StorageProvider

    init(year: Int, title: String, budgets: [Budget], storageProvider: StorageProvider, delegate: Delegate?) {
        self.year = year
        self.title = title
        self.budgets = budgets
        self.storageProvider = storageProvider
        self.delegate = delegate
    }

    // MARK: Internal methods

    func add(budget: Budget) async throws {
        try delegate?.willAdd(budget: budget)
        try await storageProvider.add(budget: budget)

        budgets.append(budget)
        try delegate?.didAdd(budget: budget)

        addNewBudgetIsPresented = false
    }

    func delete(budgetsAt offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)

            try await storageProvider.delete(budgetsWith: identifiersSet)

            budgets.remove(atOffsets: offsets)
            delegate?.didDelete(budgetsWith: identifiersSet)

            deleteBudgetError = nil

        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}
