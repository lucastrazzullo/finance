//
//  Repository.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol StorageProvider: AnyObject {

    // MARK: Report

    func fetchReport() async throws -> Report
    func add(budget: Budget) async throws -> Report
    func delete(budgetWith identifier: Budget.ID) async throws -> Report
    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Report

    // MARK: Budget

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget
    func update(budget: Budget) async throws -> Budget
}

final actor Repository {

    // MARK: Instance properties

    private let storageProvider: StorageProvider

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Budget list

    func fetchReport() async throws -> Report {
        return try await storageProvider.fetchReport()
    }

    // MARK: Budget

    func fetch(budgetWith id: Budget.ID) async throws -> Budget {
        return try await storageProvider.fetch(budgetWith: id)
    }

    func delete(budgetWith identifier: Budget.ID) async throws -> Report {
        return try await storageProvider.delete(budgetWith: identifier)
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Report {
        return try await storageProvider.delete(budgetsWith: identifiers)
    }

    func add(budget: Budget) async throws -> Report {
        let report = try await storageProvider.fetchReport()
        try report.canAdd(budget: budget)
        return try await storageProvider.add(budget: budget)
    }

    func update(budget: Budget) async throws -> Budget {
        let report = try await storageProvider.fetchReport()
        try report.canUpdate(budget: budget)
        return try await storageProvider.update(budget: budget)
    }
}
