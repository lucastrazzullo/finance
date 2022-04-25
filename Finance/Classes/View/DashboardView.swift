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

    @State var month: Int = Calendar.current.component(.month, from: .now)
    @State var addNewTransactionIsPresented: Bool = false

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
        OverviewListView(month: month, yearlyOverview: viewModel.yearlyOverview, item: makeOverviewListViewItem(overview:))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Overview \(viewModel.yearlyOverview.name)",
                        subtitle: String(viewModel.yearlyOverview.year)
                    )
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    MonthPickerView(month: $month)
                        .pickerStyle(MenuPickerStyle())
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
            .sheet(isPresented: $addNewTransactionIsPresented) {
                AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(transactions:))
            }
    }

    @ViewBuilder private func makeOverviewListViewItem(overview: MonthlyBudgetOverview) -> some View {
        NavigationLink(destination: makeExpensesListView(overview: overview)) {
            MonthlyBudgetOverviewItem(overview: overview)
        }
    }

    // MARK: Private builder methods - Transactions list

    @ViewBuilder private func makeExpensesListView(overview: MonthlyBudgetOverview) -> some View {
        let month = Calendar.current.standaloneMonthSymbols[month - 1]

        TransactionsListView(viewModel: viewModel)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Expenses \(overview.name)",
                        subtitle: "in \(month)"
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
            .sheet(isPresented: $addNewTransactionIsPresented) {
                AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(transactions:))
            }
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
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Budgets \(self.viewModel.yearlyOverview.name)",
                        subtitle: String(self.viewModel.yearlyOverview.year)
                    )
                }
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

struct DashboardView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        DashboardView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
