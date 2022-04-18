//
//  StorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import Foundation

protocol StorageProvider: AnyObject {

    // MARK: Fetch

    func fetchTransactions(year: Int) async throws -> [Transaction]
    func fetchBudgets(year: Int) async throws -> [Budget]

    // MARK: Add

    func add(transaction: Transaction) async throws
    func add(budget: Budget) async throws
    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws

    // MARK: Update

    func update(name: String, iconSystemName: String, inBudgetWith id: Budget.ID) async throws
}
