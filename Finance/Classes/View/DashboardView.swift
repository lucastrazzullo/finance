//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    let overview: YearlyBudgetOverview
    let storageProvider: StorageProvider

    var body: some View {
        TabView {
            let overviewListViewModel = StorageOverviewListViewModel(overview: overview, storageProvider: storageProvider)
            OverviewListView(viewModel: overviewListViewModel)
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            let budgetsListViewModel = StorageBudgetsListViewModel(overview: overview, storageProvider: storageProvider)
            BudgetsListView(viewModel: budgetsListViewModel, storageProvider: storageProvider)
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(overview: Mocks.overview, storageProvider: try! MockStorageProvider())
    }
}
