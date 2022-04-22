//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    @Environment(\.storageProvider) private var storageProvider
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        TabView {
            OverviewListView(
                viewModel: OverviewListViewModel(
                    yearlyOverview: viewModel.yearlyOverview,
                    storageProvider: storageProvider,
                    delegate: viewModel
                ),
                header: { DashboardHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle
                )}
            )
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            BudgetsListView(
                viewModel: BudgetsListViewModel(
                    year: viewModel.year,
                    title: viewModel.title,
                    budgets: viewModel.budgets,
                    storageProvider: storageProvider,
                    delegate: viewModel
                ),
                header: { DashboardHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle
                )}
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
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        DashboardView(viewModel: .init(storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
