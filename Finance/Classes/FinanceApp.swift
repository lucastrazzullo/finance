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
            DashboardView(
                overview: session.overview,
                addTransactions: session.add(transactions:),
                addBudget: session.add(budget:),
                deleteBudgets: session.delete(budgetsWith:),
                addSliceToBudget: session.add(slice:toBudgetWith:),
                deleteSlices: session.delete(slicesWith:inBudgetWith:),
                updateNameAndIcon: session.update(name:icon:inBudgetWith:)
            )
            .task {
                try? await session.load()
            }
            .refreshable {
                try? await session.load()
            }
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
