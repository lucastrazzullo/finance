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

    @Published var budgets: [Budget]
    @Published var deleteBudgetError: DomainError?
    @Published var addNewBudgetIsPresented: Bool = false

    let year: Int
    let title: String

    private let storageProvider: StorageProvider
    private weak var delegate: Delegate?

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

extension BudgetsListViewModel: BudgetViewModelDelegate {

    func didAdd(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        try delegate?.didAdd(slice: slice, toBudgetWith: identifier)
    }

    func didDelete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws {
        try delegate?.didDelete(slicesWith: identifiers, inBudgetWith: identifier)
    }

    func willUpdate(name: String, in budget: Budget) throws {
        try delegate?.willUpdate(name: name, in: budget)
    }

    func didUpdate(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) throws {
        try delegate?.didUpdate(name: name, icon: icon, inBudgetWith: identifier)
    }
}
