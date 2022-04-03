//
//  Repository.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol StorageProvider: AnyObject {

    // MARK: Fetch

    func fetchReport() async throws -> Report
    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget

    // MARK: Add

    func add(budget: Budget) async throws
    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID>
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws

    // MARK: Update

    func update(name: String, inBudgetWith id: Budget.ID) async throws

}

final actor Repository {

    // MARK: Instance properties

    private let storageProvider: StorageProvider

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Fetch

    func fetchReport() async throws -> Report {
        return try await storageProvider.fetchReport()
    }

    func fetch(budgetWith id: Budget.ID) async throws -> Budget {
        return try await storageProvider.fetch(budgetWith: id)
    }

    // MARK: Add

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        let budget = try await fetch(budgetWith: id)
        try budget.willAdd(slice: slice)

        try await storageProvider.add(slice: slice, toBudgetWith: id)
    }

    func add(budget: Budget) async throws {
        let report = try await fetchReport()
        try report.willAdd(budget: budget)

        try await storageProvider.add(budget: budget)
    }

    // MARK: Delete

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws {
        let budget = try await fetch(budgetWith: id)
        try budget.willDelete(slicesWith: identifiers)

        return try await storageProvider.delete(slicesWith: identifiers, inBudgetWith: id)
    }

    @discardableResult
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID> {
        return try await storageProvider.delete(budgetsWith: identifiers)
    }

    // MARK: Update

    func update(name: String, inBudgetWith id: Budget.ID) async throws {
        let report = try await fetchReport()
        try report.willUpdate(budgetName: name)

        let budget = try await fetch(budgetWith: id)
        try budget.willUpdate(name: name)

        try await storageProvider.update(name: name, inBudgetWith: id)
    }
}
