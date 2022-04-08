//
//  OverviewController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class OverviewController: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview

    private let repository: Repository

    // MARK: Object life cycle

    init(overview: YearlyBudgetOverview, storageProvider: StorageProvider) {
        self.overview = overview
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Internal methods

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: overview.year)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }

    func add(budget: Budget) async throws {
        try await repository.add(budget: budget)

        DispatchQueue.main.async { [weak self] in
            try? self?.overview.append(budget: budget)
        }
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        let budgetsIdentifiersToDelete = overview.budgetIdentifiers(at: indices)
        let deletedIdentifiers = try await repository.delete(budgetsWith: budgetsIdentifiersToDelete)

        DispatchQueue.main.async { [weak self] in
            self?.overview.delete(budgetsWith: deletedIdentifiers)
        }
    }
}
