//
//  BudgetController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class BudgetController: ObservableObject {

    @Published var budget: Budget

    private var budgetProvider: BudgetProvider

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.budget = budget
        self.budgetProvider = budgetProvider
    }

    // MARK: Budget

    func fetch() {
        let budgetId = budget.id
        Task { [weak self] in
            do {
                guard let budget = try await self?.budgetProvider.fetchBudget(with: budgetId) else {
                    throw DomainError.budget(error: .cannotFetchTheBudget(id: budgetId))
                }
                DispatchQueue.main.async { [weak self] in
                    self?.budget = budget
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    func update(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        let budget = budget
        Task { [weak self] in
            do {
                guard let budget = try await self?.budgetProvider.update(budget: budget) else {
                    throw DomainError.budget(error: .cannotUpdateTheBudget(underlyingError: nil))
                }
                DispatchQueue.main.async { [weak self] in
                    self?.budget = budget
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: error)))
            }
        }
    }
}
