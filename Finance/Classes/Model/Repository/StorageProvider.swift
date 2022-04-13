//
//  StorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol StorageProvider: AnyObject {

    // MARK: Fetch

    func fetchYearlyOverview(year: Int) async throws -> YearlyBudgetOverview
    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget

    // MARK: Add

    func add(budget: Budget) async throws
    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID>
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws

    // MARK: Update

    func update(name: String, iconSystemName: String?, inBudgetWith id: Budget.ID) async throws
}
