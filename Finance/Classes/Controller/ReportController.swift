//
//  ReportController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class ReportController: ObservableObject {

    @Published private(set) var report: Report

    private let repository: Repository

    // MARK: Object life cycle

    init(report: Report, storageProvider: StorageProvider) {
        self.report = report
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Internal methods

    func fetch() async throws {
        let report = try await repository.fetchReport()

        DispatchQueue.main.async { [weak self] in
            self?.report = report
        }
    }

    func add(budget: Budget) async throws {
        try await repository.add(budget: budget)

        DispatchQueue.main.async { [weak self] in
            try? self?.report.append(budget: budget)
        }
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        let budgetsIdentifiersToDelete = report.budgetIdentifiers(at: indices)
        let deletedIdentifiers = try await repository.delete(budgetsWith: budgetsIdentifiersToDelete)

        DispatchQueue.main.async { [weak self] in
            self?.report.delete(budgetsWith: deletedIdentifiers)
        }
    }
}
