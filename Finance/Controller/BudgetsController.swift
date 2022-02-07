//
//  BudgetsController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class BudgetsController: ObservableObject {

    @Published var budgets: [Budget]

    private(set) var budgetProvider: BudgetProvider

    init(budgetProvider: BudgetProvider) {
        self.budgetProvider = budgetProvider
        self.budgets = []
    }

    // MARK: Internal methods

    func fetch() {
        Task { [weak self] in
            do {
                guard let budgets = try await self?.budgetProvider.fetchBudgets() else {
                    throw DomainError.budgets(error: .cannotFetchTheBudgets)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.budgets = budgets
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    func add(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        Task { [weak self] in
            do {
                guard let budgets = try await self?.budgetProvider.add(budget: budget) else {
                    throw DomainError.budgets(error: .budgetDoesntExist)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.budgets = budgets
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: error)))
            }
        }
    }

    func delete(budgetsAt offsets: IndexSet, completion: @escaping (Result<Void, DomainError>) -> Void) {
        Task { [weak self] in
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

            do {
                guard let budgets = try await self?.budgetProvider.delete(budgets: budgetsToDelete) else {
                    throw DomainError.budgets(error: .budgetDoesntExist)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.budgets = budgets
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: error)))
            }
        }
    }
}
