//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main
struct FinanceApp: App {

    @State private var overview: YearlyBudgetOverview?
    @State private var loadError: DomainError?

    private let repository: Repository

    var body: some Scene {
        WindowGroup {
            if let overview = overview {
                DashboardView(overview: overview, repository: repository)
            } else if let error = loadError {
                ErrorView(error: error, retryAction: load)
            } else {
                ProgressView("Loading").onAppear(perform: load)
            }
        }
    }

    // MARK: Private helper methods

    private func load() {
        Task {
            do {
                overview = try await repository.fetchYearlyOverview(year: 2022)
                loadError = nil
            } catch {
                loadError = error as? DomainError
            }
        }
    }

    // MARK: Object life cycle

    init() {
        let storageProvider: StorageProvider = {
            if CommandLine.arguments.contains("testing") {
                return try! MockStorageProvider()
            } else {
                return CoreDataStorageProvider()
            }
        }()

        self.repository = Repository(storageProvider: storageProvider)
    }
}
