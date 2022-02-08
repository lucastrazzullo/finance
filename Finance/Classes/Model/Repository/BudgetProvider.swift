//
//  ReportProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 20/01/2022.
//

import Foundation

protocol ReportStorageProvider: AnyObject {

    // MARK: Report

    func fetchReport() async throws -> Report
    func add(budget: Budget) async throws -> Report
    func delete(budget: Budget) async throws -> Report
    func delete(budgets: [Budget]) async throws -> Report

    // MARK: Budget

    func fetchBudget(with identifier: Budget.ID) async throws -> Budget
    func updateBudget(budget: Budget) async throws -> Budget
}

final actor ReportProvider {

    // MARK: Instance properties

    private let storageProvider: ReportStorageProvider

    init(storageProvider: ReportStorageProvider) {
        self.storageProvider = storageProvider
    }

    // MARK: Budget list

    func fetchReport() async throws -> Report {
        return try await storageProvider.fetchReport()
    }

    func add(budget: Budget) async throws -> Report {
        let report = try await storageProvider.fetchReport()
        try report.canAdd(budget: budget)
        return try await storageProvider.add(budget: budget)
    }

    func delete(budget: Budget) async throws -> Report {
        return try await storageProvider.delete(budget: budget)
    }

    func delete(budgets: [Budget]) async throws -> Report {
        return try await storageProvider.delete(budgets: budgets)
    }

    // MARK: Budget

    func fetchBudget(with id: Budget.ID) async throws -> Budget {
        return try await storageProvider.fetchBudget(with: id)
    }

    func update(budget: Budget) async throws -> Budget {
        let report = try await storageProvider.fetchReport()
        try report.canUpdate(budget: budget)
        return try await storageProvider.updateBudget(budget: budget)
    }
}
