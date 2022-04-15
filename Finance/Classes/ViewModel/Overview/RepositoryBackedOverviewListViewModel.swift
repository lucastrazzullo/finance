//
//  RepositoryBackedOverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class RepositoryBackedOverviewListViewModel: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview

    private let repository: Repository

    // MARK: Object life cycle

    init(overview: YearlyBudgetOverview, repository: Repository) {
        self.overview = overview
        self.repository = repository
    }
}

extension RepositoryBackedOverviewListViewModel: OverviewListViewModel {

    var title: String {
        overview.name
    }

    var subtitle: String {
        "Overview \(String(overview.year))"
    }

    var budgets: [Budget] {
        return overview.budgets
    }

    func fetch() async throws {
        let overview = try await repository.fetchYearlyOverview(year: overview.year)

        DispatchQueue.main.async { [weak self] in
            self?.overview = overview
        }
    }

    func overviews(for month: Int) -> [MonthlyBudgetOverview] {
        overview.monthlyOverviews(month: month)
    }

    func add(transactions: [Transaction]) async throws {
        overview.append(transactions: transactions)
    }
}
