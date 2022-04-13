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

    private let year: Int
    private let storageProvider: StorageProvider

    var body: some Scene {
        WindowGroup {
            if let overview = overview {
                DashboardView(overview: overview, storageProvider: storageProvider)
            } else {
                Text("Loading overview ...")
                    .onAppear {
                        Task {
                            overview = try? await storageProvider.fetchYearlyOverview(year: year)
                        }
                    }
            }
        }
    }

    // MARK: Object life cycle

    init() {
        self.year = 2022
        self.storageProvider = {
            if CommandLine.arguments.contains("testing") {
                return try! MockStorageProvider()
            } else {
                return CoreDataStorageProvider()
            }
        }()
    }
}
