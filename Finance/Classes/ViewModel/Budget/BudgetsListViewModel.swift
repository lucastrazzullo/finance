//
//  BudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol BudgetsListViewModel: ObservableObject {
    var year: Int { get }
    var title: String { get }
    var subtitle: String { get }
    var budgets: [Budget] { get }

    func fetch() async throws
    func add(budget: Budget) async throws
    func delete(budgetsAt indices: IndexSet) async throws
}
