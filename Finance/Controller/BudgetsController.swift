//
//  BudgetsController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class BudgetsController: ObservableObject {

    @Published var budgets: Budgets

    private(set) weak var budgetProvider: BudgetProvider?

    init(budgetProvider: BudgetProvider) {
        self.budgetProvider = budgetProvider
        self.budgets = Budgets()
    }

    // MARK: Internal methods

    func fetch() {
        budgetProvider?.fetchBudgets { [weak self] result in
            switch result {
            case .success(let budgets):
                self?.budgets = Budgets(list: budgets)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }

    func add(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try budgets.canAdd(budget: budget)
            budgetProvider?.add(budget: budget) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }

    func delete(budgetsAt offsets: IndexSet, completion: @escaping (Result<Void, DomainError>) -> Void) {
        let list = budgets.list
        let budgetsToDelete = offsets.compactMap { index -> Budget? in
            guard list.indices.contains(index) else {
                return nil
            }
            return list[index]
        }

        guard !budgetsToDelete.isEmpty else {
            completion(.failure(.budgets(error: .budgetDoesntExist)))
            return
        }

        do {
            try budgetsToDelete.forEach { budget in
                try budgets.canRemove(budget: budget)
            }

            budgetProvider?.delete(budgets: budgetsToDelete) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }
}
