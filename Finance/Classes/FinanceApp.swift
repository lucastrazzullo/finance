//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main struct FinanceApp: App {

    @ObservedObject private var session: FinanceSession

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: .init(
                yearlyOverview: session.yearlyOverview,
                handler: session
            ))
        }
    }

    init() {
        if CommandLine.arguments.contains("testing") {
            session = FinanceSession(storageProvider: MockStorageProvider())
        } else {
            session = FinanceSession(storageProvider: CoreDataStorageProvider())
        }
    }
}
