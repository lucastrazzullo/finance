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

    // MARK: Overview

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: overview.year)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }
}

extension OverviewController: BudgetsListViewModel {

    var listYear: Int {
        overview.year
    }

    var listTitle: String {
        overview.name
    }

    var listSubtitle: String {
        "Budgets \(String(overview.year))"
    }

    var listBudgets: [Budget] {
        overview.budgets
    }

    // MARK: Methods

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

extension OverviewController: OverviewListViewModel {

    var overviewTitle: String {
        overview.name
    }

    var overviewSubtitle: String {
        "Overview \(String(overview.year))"
    }

    var overviewBudgets: [Budget] {
        return overview.budgets
    }

    func overviews(for month: Int) -> [MonthlyBudgetOverview] {
        overview.monthlyOverviews(month: month)
    }

    func add(transaction: Transaction) async throws {
        overview.append(transaction: transaction)
    }
}
