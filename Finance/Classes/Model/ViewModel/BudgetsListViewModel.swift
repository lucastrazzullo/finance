//
//  BudgetsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol BudgetsListViewModel: ObservableObject {
    var listYear: Int { get }
    var listTitle: String { get }
    var listSubtitle: String { get }
    var listBudgets: [Budget] { get }

    func fetch() async throws
    func add(budget: Budget) async throws
    func delete(budgetsAt indices: IndexSet) async throws
}
