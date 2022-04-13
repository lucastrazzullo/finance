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

    private let storageProvider: StorageProvider = {
        if CommandLine.arguments.contains("testing") {
            return try! MockStorageProvider()
        } else {
            return CoreDataStorageProvider()
        }
    }()

    var body: some Scene {
        WindowGroup {
            if let overview = overview {
                DashboardView(overview: overview, storageProvider: storageProvider)
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
                let repository: Repository = Repository(storageProvider: storageProvider)
                overview = try await repository.fetchYearlyOverview(year: 2022)
                loadError = nil
            } catch {
                loadError = error as? DomainError
            }
        }
    }
}
