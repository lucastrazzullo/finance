//
//  OverviewListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol OverviewListViewModel: ObservableObject {
    var overviewTitle: String { get }
    var overviewSubtitle: String { get }
    var overviewBudgets: [Budget] { get }

    func fetch() async throws
    func add(transaction: Transaction) async throws

    func overviews(for month: Int) -> [MonthlyBudgetOverview]
}

extension OverviewListViewModel {

    func overviewsWithLowestAvailability(for month: Int) -> [MonthlyBudgetOverview] {
        overviews(for: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }
}
