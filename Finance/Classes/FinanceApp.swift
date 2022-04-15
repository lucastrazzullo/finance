//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main
struct FinanceApp: App {

    @Environment(\.repository) private var repository

    @State private var overview: YearlyBudgetOverview?
    @State private var loadError: DomainError?

    var body: some Scene {
        WindowGroup {
            if let overview = overview {
                DashboardView(overview: overview)
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
}

struct ReporitoryKey: EnvironmentKey {

    static let defaultValue: Repository = {
        let storageProvider: StorageProvider = {
            if CommandLine.arguments.contains("testing") {
                return try! MockStorageProvider()
            } else {
                return CoreDataStorageProvider()
            }
        }()

        return Repository(storageProvider: storageProvider)
    }()
}

extension EnvironmentValues {

    var repository: Repository {
        get {
            return self[ReporitoryKey.self]
        }
        set {
            self[ReporitoryKey.self] = newValue
        }
    }
}
