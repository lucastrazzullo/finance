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

            NavigationView {
                makeBudgetsListView()
            }
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

    // MARK: Private builder methods

    @ViewBuilder private func makeBudgetsListView() -> some View {
        let viewModel = BudgetsListViewModel(
            year: viewModel.year,
            budgets: viewModel.budgets,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        BudgetsListView(viewModel: viewModel, item: makeBudgetListItem(budget:))
    }

    @ViewBuilder private func makeBudgetListItem(budget: Budget) -> some View {
        NavigationLink(destination: makeBudgetView(budget: budget), label: {
            BudgetsListItem(budget: budget)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: EditButton())
                .toolbar {
                    DashboardHeader(
                        title: viewModel.title,
                        subtitle: viewModel.subtitle
                    )
                }
        })
    }

    @ViewBuilder private func makeBudgetView(budget: Budget) -> some View {
        let viewModel = BudgetViewModel(
            budget: budget,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        BudgetView(viewModel: viewModel)
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
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        DashboardView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
