//
//  OverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol OverviewListViewModel: ObservableObject {
    var title: String { get }
    var subtitle: String { get }
    var overview: YearlyBudgetOverview { get }

    func fetch() async throws
    func add(transactions: [Transaction]) async throws

    func overviews(for month: Int) -> [MonthlyBudgetOverview]
}

extension OverviewListViewModel {

    func overviewsWithLowestAvailability(for month: Int) -> [MonthlyBudgetOverview] {
        overviews(for: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }
}
