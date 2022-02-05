//
//  BudgetsController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class BudgetsController: ObservableObject {

    @Published var budgets: [Budget]

    private(set) var budgetProvider: BudgetProvider?

    init(budgetProvider: BudgetProvider) {
        self.budgetProvider = budgetProvider
        self.budgets = []
    }

    // MARK: Internal methods

    func fetch() {
        budgetProvider?.fetchBudgets { [weak self] result in
            switch result {
            case .success(let budgets):
                self?.budgets = budgets
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }

    func add(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        budgetProvider?.add(budget: budget) { [weak self] result in
            switch result {
            case .success(let budgets):
                self?.budgets = budgets
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(budgetsAt offsets: IndexSet, completion: @escaping (Result<Void, DomainError>) -> Void) {
        let budgetsToDelete = offsets.compactMap { index -> Budget? in
            guard budgets.indices.contains(index) else {
                return nil
            }
            return budgets[index]
        }

        guard !budgetsToDelete.isEmpty else {
            completion(.failure(.budgets(error: .budgetDoesntExist)))
            return
        }

        budgetProvider?.delete(budgets: budgetsToDelete) { [weak self] result in
            switch result {
            case .success(let budgets):
                self?.budgets = budgets
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
