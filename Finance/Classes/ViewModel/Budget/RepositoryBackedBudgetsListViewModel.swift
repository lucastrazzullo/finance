//
//  RepositoryBackedBudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 15/04/2022.
//

import Foundation

final class RepositoryBackedBudgetsListViewModel: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview

    private let repository: Repository

    // MARK: Object life cycle

    init(overview: YearlyBudgetOverview, repository: Repository) {
        self.overview = overview
        self.repository = repository
    }
}

extension RepositoryBackedBudgetsListViewModel: BudgetsListViewModel {

    var year: Int {
        overview.year
    }

    var title: String {
        overview.name
    }

    var subtitle: String {
        "Budgets \(String(overview.year))"
    }

    var budgets: [Budget] {
        overview.budgets
    }

    // MARK: Methods

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: overview.year)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }

    func add(budget: Budget) async throws {
        try await repository.add(budget: budget)

        DispatchQueue.main.async { [weak self] in
            self?.overview.append(budget: budget)
        }
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        let budgetList = BudgetList(budgets: overview.budgets)
        let budgetsIdentifiersToDelete = budgetList.budgetIdentifiers(at: indices)
        let deletedIdentifiers = try await repository.delete(budgetsWith: budgetsIdentifiersToDelete)

        DispatchQueue.main.async { [weak self] in
            self?.overview.delete(budgetsWithIdentifiers: deletedIdentifiers)
        }
    }
}
