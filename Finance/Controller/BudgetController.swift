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

    // MARK: Budget

    func fetch() {
        budgetProvider?.fetchBudget(with: budget.id) { [weak self] result in
            switch result {
            case .success(let budget):
                self?.budget = budget
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    // MARK: Properties

    func update(name: String, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try Budget.canUse(name: name)
            budgetProvider?.update(name: name, inBudgetWith: budget.id) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }

    // MARK: Slices

    func add(slice: BudgetSlice, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try budget.canAdd(newSlice: slice)
            budgetProvider?.add(budgetSlice: slice, toBudgetWith: budget.id) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }

    func delete(slice: BudgetSlice, completion: @escaping (Result<Void, DomainError>) -> Void) {
        do {
            try budget.canRemove(slice: slice)
            budgetProvider?.delete(budgetSlice: slice) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        } catch {
            completion(.failure(.with(error: error)))
        }
    }
}
