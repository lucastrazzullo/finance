//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main
struct FinanceApp: App {

    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("testing") {
                DashboardView(storageProvider: MockStorageProvider(overviewYear: 2022))
            } else {
                DashboardView(storageProvider: CoreDataStorageProvider())
            }
        }
    }
}
