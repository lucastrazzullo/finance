//
//  BudgetController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class BudgetController: ObservableObject {

    @Published var budget: Budget

    private weak var budgetProvider: BudgetProvider?

    var monthlyAmount: MoneyValue {
        budget.amount
    }

    var yearlyAmount: MoneyValue {
        budget.amount * .value(12)
    }

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.budget = budget
        self.budgetProvider = budgetProvider
    }

    // MARK: Internal methods

    func add(slice: BudgetSlice, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try budget.add(slice: slice)
            budgetProvider?.add(budgetSlice: slice, toBudgetWith: budget.id) { [weak self] result in
                if case .failure = result {
                    try? self?.budget.remove(slice: slice)
                }
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }

    func delete(slice: BudgetSlice, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try budget.remove(slice: slice)
            budgetProvider?.delete(budgetSlice: slice) { [weak self] result in
                if case .failure = result {
                    try? self?.budget.add(slice: slice)
                }
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }
}
