//
//  YearlyOverviewView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct YearlyOverviewView: View {

    @Environment(\.storageProvider) private var storageProvider

    @ObservedObject var viewModel: YearlyOverviewViewModel

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
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.budgetsTab)
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
        YearlyOverviewListView(
            item: makeOverviewListViewItem(overview:),
            yearlyOverview: viewModel.yearlyOverview,
            month: viewModel.month
        )
        .sheet(isPresented: $viewModel.addNewTransactionIsPresented) {
            AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(transactions:))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                DefaultToolbar(
                    title: "Overview \(viewModel.yearlyOverview.name)",
                    subtitle: String(viewModel.yearlyOverview.year)
                )
            }

            ToolbarItem(placement: .navigationBarLeading) {
                MonthPickerView(month: $viewModel.month)
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
        NavigationLink(destination: makeExpensesListView(overview: overview)) {
            MonthlyOverviewItem(overview: overview)
        }
    }

    // MARK: Private builder methods - Transactions

    @ViewBuilder private func makeExpensesListView(overview: MonthlyBudgetOverview) -> some View {
        let month = Calendar.current.standaloneMonthSymbols[viewModel.month - 1]

        TransactionsListView(viewModel: viewModel)
            .sheet(isPresented: $viewModel.addNewTransactionIsPresented) {
                AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(transactions:))
            }
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Expenses \(overview.name)",
                        subtitle: "in \(month)"
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
    }

    // MARK: Private builder methods - Budgets

    @ViewBuilder private func makeBudgetsListView() -> some View {
        let viewModel = BudgetsListViewModel(dataProvider: viewModel)
        BudgetsListView(viewModel: viewModel, item: makeBudgetListItem(budget:))
            .navigationBarTitleDisplayMode(.inline)
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
            dataProvider: viewModel
        )

        BudgetView(viewModel: viewModel)
    }
}

struct YearlyOverviewView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        YearlyOverviewView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
