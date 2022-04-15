//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    @Environment(\.repository) private var repository

    let overview: YearlyBudgetOverview

    var body: some View {
        TabView {
            let overviewListViewModel = RepositoryBackedOverviewListViewModel(overview: overview, repository: repository)
            OverviewListView(viewModel: overviewListViewModel)
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            let budgetsListViewModel = RepositoryBackedBudgetsListViewModel(overview: overview, repository: repository)
            BudgetsListView(viewModel: budgetsListViewModel)
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(overview: Mocks.overview)
    }
}
