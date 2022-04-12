//
//  OverviewController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class OverviewController: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview?

    private let year: Int
    private let repository: Repository

    // MARK: Object life cycle

    init(year: Int, storageProvider: StorageProvider) {
        self.year = year
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Overview

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: year)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }

    // MARK: Budget

    func add(budget: Budget) async throws {
        try await repository.add(budget: budget)

        DispatchQueue.main.async { [weak self] in
            self?.overview?.append(budget: budget)
        }
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        guard let overview = overview else {
            return
        }

        let budgetList = BudgetList(budgets: overview.budgets)
        let budgetsIdentifiersToDelete = budgetList.budgetIdentifiers(at: indices)
        let deletedIdentifiers = try await repository.delete(budgetsWith: budgetsIdentifiersToDelete)

        DispatchQueue.main.async { [weak self] in
            self?.overview?.delete(budgetsWithIdentifiers: deletedIdentifiers)
        }
    }

    // MARK: Transaction

    func add(transaction: Transaction) {
        overview?.append(transaction: transaction)
    }
}
