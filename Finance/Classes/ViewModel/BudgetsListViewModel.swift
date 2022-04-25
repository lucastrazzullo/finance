//
//  BudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetsListViewModel: ObservableObject {
    var year: Int { get }
    var budgets: [Budget] { get }

    func add(budget: Budget) async throws
    func delete(budgetsAt offsets: IndexSet) async throws
}
