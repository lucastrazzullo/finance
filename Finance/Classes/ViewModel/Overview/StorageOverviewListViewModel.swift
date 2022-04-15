//
//  StorageOverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class StorageOverviewListViewModel: ObservableObject {

    @Published private(set) var overview: YearlyBudgetOverview

    private let repository: Repository

    // MARK: Object life cycle

    init(overview: YearlyBudgetOverview, storageProvider: StorageProvider) {
        self.overview = overview
        self.repository = Repository(storageProvider: storageProvider)
    }
}

extension StorageOverviewListViewModel: OverviewListViewModel {

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

    func add(transaction: Transaction) async throws {
        overview.append(transaction: transaction)
    }
}
