//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main
struct FinanceApp: App {

    private let year: Int = 2022

    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("testing") {
                DashboardView(overviewYear: year, storageProvider: MockStorageProvider(overviewYear: year))
            } else {
                DashboardView(overviewYear: year, storageProvider: CoreDataStorageProvider())
            }
        }
    }
}
