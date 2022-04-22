//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        TabView {
            OverviewListView(
                header: { DashboardHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle
                )},
                viewModel: .init(
                    yearlyOverview: viewModel.yearlyOverview,
                    handler: viewModel.handler
                )
            )
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            BudgetsListView(
                header: { DashboardHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle
                )},
                viewModel: .init(
                    year: viewModel.year,
                    title: viewModel.title,
                    budgets: viewModel.budgets,
                    handler: viewModel.handler
                )
            )
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
        .task {
            try? await viewModel.load()
        }
        .refreshable {
            try? await viewModel.load()
        }
    }
}

struct DashboardHeader: ToolbarContent {

    var title: String
    var subtitle: String

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            DefaultToolbar(
                title: title,
                subtitle: subtitle
            )
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: .init(
                yearlyOverview: .init(
                    name: "Mock",
                    year: Mocks.year,
                    budgets: Mocks.budgets,
                    expenses: Mocks.transactions
                ),
                handler: nil
            )
        )
    }
}
