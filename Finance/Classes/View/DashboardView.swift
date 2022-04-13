//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    @ObservedObject private var overviewController: OverviewController

    private let storageProvider: StorageProvider

    var body: some View {
        TabView {
            OverviewListView(viewModel: overviewController)
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            BudgetsListView(
                destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
                viewModel: overviewController
            )
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
        .onAppear {
            Task {
                try? await overviewController.fetch()
            }
        }
    }

    // MARK: Object life cycle

    init(overview: YearlyBudgetOverview, storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.overviewController = OverviewController(overview: overview, storageProvider: storageProvider)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static let storageProvider = try! MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        DashboardView(overview: Mocks.overview, storageProvider: storageProvider)
    }
}
