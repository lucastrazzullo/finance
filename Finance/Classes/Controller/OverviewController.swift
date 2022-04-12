//
//  OverviewController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class OverviewController: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview?

    private let overviewYear: Int
    private let repository: Repository

    // MARK: Object life cycle

    init(overviewYear: Int, storageProvider: StorageProvider) {
        self.overviewYear = overviewYear
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Internal methods

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: overviewYear)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }

    func add(budget: Budget) async throws {
        try await repository.add(budget: budget)

        DispatchQueue.main.async { [weak self] in
            try? self?.overview?.append(budget: budget)
        }
    }

    func add(transaction: Transaction) {
        overview?.append(transaction: transaction)
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        guard let budgetsIdentifiersToDelete = overview?.budgetIdentifiers(at: indices) else {
            return
        }
        let deletedIdentifiers = try await repository.delete(budgetsWith: budgetsIdentifiersToDelete)

        DispatchQueue.main.async { [weak self] in
            self?.overview?.delete(budgetsWith: deletedIdentifiers)
        }
    }
}
