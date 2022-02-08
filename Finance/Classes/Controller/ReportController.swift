//
//  ReportController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class ReportController: ObservableObject {

    @Published var report: Report

    let storageProvider: StorageProvider
    private let repository: Repository

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.repository = Repository(storageProvider: storageProvider)
        self.report = Report(budgets: [])
    }

    // MARK: Internal methods

    func fetch() {
        Task { [weak self] in
            do {
                guard let report = try await self?.repository.fetchReport() else {
                    throw DomainError.report(error: .cannotFetchTheBudgets)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.report = report
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    func add(budget: Budget, completion: @escaping (Result<Void, DomainError>) -> Void) {
        Task { [weak self] in
            do {
                guard let report = try await self?.repository.add(budget: budget) else {
                    throw DomainError.report(error: .budgetDoesntExist)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.report = report
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: error)))
            }
        }
    }

    func delete(budgetsAt offsets: IndexSet, completion: @escaping (Result<Void, DomainError>) -> Void) {
        Task { [weak self] in
            let budgetsToDelete = report.budgets(at: offsets)
            guard !budgetsToDelete.isEmpty else {
                completion(.failure(.report(error: .budgetDoesntExist)))
                return
            }

            do {
                guard let report = try await self?.repository.delete(budgets: budgetsToDelete) else {
                    throw DomainError.report(error: .budgetDoesntExist)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.report = report
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: error)))
            }
        }
    }
}
