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
            NavigationView {
                makeOverviewListView()
            }
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

    // MARK: Private builder methods - Overview

    @ViewBuilder private func makeOverviewListView() -> some View {
        let viewModel = OverviewListViewModel(
            month: viewModel.month,
            yearlyOverview: viewModel.yearlyOverview,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        OverviewListView(viewModel: viewModel, item: makeOverviewListViewItem(overview:))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                DashboardHeader(
                    title: self.viewModel.title,
                    subtitle: self.viewModel.subtitle
                )

                ToolbarItem(placement: .navigationBarLeading) {
                    MonthPickerView(month: self.$viewModel.month)
                        .pickerStyle(MenuPickerStyle())
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
    }

    @ViewBuilder private func makeOverviewListViewItem(overview: MonthlyBudgetOverview) -> some View {
        NavigationLink(destination: makeTransactionsListView(overview: overview)) {
            MonthlyBudgetOverviewItem(overview: overview)
        }
    }

    // MARK: Private builder methods - Transactions list

    @ViewBuilder private func makeTransactionsListView(overview: MonthlyBudgetOverview) -> some View {
        let month = Calendar.current.standaloneMonthSymbols[self.viewModel.month - 1]
        let viewModel = TransactionsListViewModel(
            transactions: overview.totalExpenses,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        TransactionsListView(viewModel: viewModel)
            .navigationTitle("Expenses \(overview.name), in \(month)")
    }

    // MARK: Private builder methods - Budgets list

    @ViewBuilder private func makeBudgetsListView() -> some View {
        let viewModel = BudgetsListViewModel(
            year: viewModel.year,
            budgets: viewModel.budgets,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        BudgetsListView(viewModel: viewModel, item: makeBudgetListItem(budget:))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .toolbar {
                DashboardHeader(
                    title: self.viewModel.title,
                    subtitle: self.viewModel.subtitle
                )
            }
    }

    @ViewBuilder private func makeBudgetListItem(budget: Budget) -> some View {
        NavigationLink(destination: makeBudgetView(budget: budget), label: {
            BudgetsListItem(budget: budget)
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
