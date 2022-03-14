//
//  ReportController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

final class ReportController: ObservableObject {

    @Published var report: Report?

    let storageProvider: StorageProvider
    private let repository: Repository

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.repository = Repository(storageProvider: storageProvider)
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
                completion(.failure(error as? DomainError ?? .underlying(error: .swiftError(error: error))))
            }
        }
    }

    func delete(budgetsAt offsets: IndexSet, completion: @escaping (Result<Void, DomainError>) -> Void) {
        Task { [weak self] in
            guard let report = report else {
                completion(.failure(.report(error: .reportIsNotLoaded)))
                return
            }

            let budgetsIdentifiersToDelete = Set(report.budgets(at: offsets).map(\.id))
            guard !budgetsIdentifiersToDelete.isEmpty else {
                completion(.failure(.report(error: .budgetDoesntExist)))
                return
            }

            do {
                guard let report = try await self?.repository.delete(budgetsWith: budgetsIdentifiersToDelete) else {
                    throw DomainError.report(error: .budgetDoesntExist)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.report = report
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error as? DomainError ?? .underlying(error: .swiftError(error: error))))
            }
        }
    }
}
