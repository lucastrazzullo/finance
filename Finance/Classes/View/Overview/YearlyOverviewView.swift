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
        MontlyOverviewsListView(
            item: makeOverviewListViewItem(overview:),
            montlhyOverviews: viewModel.yearlyOverview.monthlyOverviews(month: viewModel.month),
            monthlyOverviewsWithLowestAvailability: viewModel.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: viewModel.month)
        )
        .sheet(isPresented: $viewModel.isAddNewTransactionPresented) {
            AddTransactionsView(budgets: viewModel.yearlyOverview.budgets, onSubmit: viewModel.add(transactions:))
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
                Button(action: { viewModel.isAddNewTransactionPresented = true }) {
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

    // MARK: Private builder methods - Budgets

    @ViewBuilder private func makeBudgetsListView() -> some View {
        let year = viewModel.yearlyOverview.year
        let budgets = viewModel.yearlyOverview.budgets
        let viewModel = BudgetsListViewModel(budgets: budgets, dataProvider: viewModel)

        BudgetsListView(viewModel: viewModel, item: makeBudgetListItem(budget:), year: year)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Budgets \(self.viewModel.yearlyOverview.name)",
                        subtitle: String(year)
                    )
                }
            }
    }

    @ViewBuilder private func makeBudgetListItem(budget: Budget) -> some View {
        let budgetViewModel = BudgetViewModel(budget: budget, dataProvider: viewModel)
        let budgetView = BudgetView(viewModel: budgetViewModel)

        NavigationLink(destination: budgetView, label: {
            BudgetsListItem(budget: budget)
        })
    }

    // MARK: Private builder methods - Expenses

    @ViewBuilder private func makeExpensesListView(overview: MonthlyBudgetOverview) -> some View {
        let viewModel = TransactionsListViewModel(transactions: overview.expensesInMonth, dataProvider: viewModel)

        TransactionsListView(viewModel: viewModel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: "Expenses \(overview.name)",
                        subtitle: "in \(Calendar.current.standaloneMonthSymbols[overview.month - 1])"
                    )
                }
            })
    }
}

struct YearlyOverviewView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        YearlyOverviewView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
