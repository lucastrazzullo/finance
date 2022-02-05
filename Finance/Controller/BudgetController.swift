//
//  BudgetController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class BudgetController: ObservableObject {

    @Published var budget: Budget

    private var budgetProvider: BudgetProvider?

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.budget = budget
        self.budgetProvider = budgetProvider
    }

    // MARK: Budget

    func fetch() {
        budgetProvider?.fetchBudget(with: budget.id) { [weak self] result in
            switch result {
            case .success(let budget):
                self?.budget = budget
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }

    func update(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        fatalError()
    }
}
