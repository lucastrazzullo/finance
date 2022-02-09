//
//  BudgetController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class BudgetController: ObservableObject {

    @Published var budget: Budget

    private var repository: Repository

    init(budget: Budget, storageProvider: StorageProvider) {
        self.budget = budget
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Budget

    func fetch() {
        let budgetId = budget.id
        Task { [weak self] in
            do {
                guard let budget = try await self?.repository.fetch(budgetWith: budgetId) else {
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
                guard let budget = try await self?.repository.update(budget: budget) else {
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
