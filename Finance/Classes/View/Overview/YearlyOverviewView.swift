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

    @State private var month: Int = Calendar.current.component(.month, from: .now)

    var body: some View {
        TabView {
            NavigationView {
                makeOverviewListView()
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
            }
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView()
            }
            .tabItem {
                Label("Transactions", systemImage: "note.text")
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.transactionsTab)
            }
        }
        .sheet(isPresented: $viewModel.isAddNewTransactionPresented) {
            AddTransactionsView(
                budgets: viewModel.yearlyOverview.budgets,
                onSubmit: viewModel.add(transactions:)
            )
        }
        .sheet(isPresented: $viewModel.isAddNewBudgetPresented) {
            NewBudgetView(
                year: viewModel.yearlyOverview.year,
                onSubmit: viewModel.add(budget:)
            )
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
            montlhyOverviews: viewModel.yearlyOverview.monthlyOverviews(month: month),
            monthlyOverviewsWithLowestAvailability: viewModel.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month)
        )
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
                Button(action: { viewModel.isAddNewTransactionPresented = true }) {
                    Label("New transaction", systemImage: "plus")
                }
            }
        })
    }

    @ViewBuilder private func makeOverviewListViewItem(overview: MonthlyBudgetOverview) -> some View {
        NavigationLink(destination: makeTransactionsListView(overview: overview)) {
            MonthlyOverviewItem(overview: overview)
        }
    }

    // MARK: Private builder methods - Budgets

    @ViewBuilder private func makeBudgetsListView() -> some View {
        let year = viewModel.yearlyOverview.year
        let budgets = viewModel.yearlyOverview.budgets
        let viewModel = BudgetsListViewModel(budgets: budgets, dataProvider: viewModel)

        BudgetsListView(
            viewModel: viewModel,
            item: makeBudgetListItem(budget:),
            addNewBudget: { self.viewModel.isAddNewBudgetPresented = true }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DefaultToolbar(
                    title: "Budgets \(self.viewModel.yearlyOverview.name)",
                    subtitle: String(year)
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { self.viewModel.isAddNewBudgetPresented = true }) {
                    Label("New budget", systemImage: "plus")
                }
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

    @ViewBuilder private func makeTransactionsListView(overview: MonthlyBudgetOverview) -> some View {
        let viewModel = TransactionsListViewModel(transactions: overview.expensesInMonth, dataProvider: viewModel)

        TransactionsListView(
            viewModel: viewModel,
            addNewTransaction: { self.viewModel.isAddNewTransactionPresented = true }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                DefaultToolbar(
                    title: "Expenses \(overview.name)",
                    subtitle: "in \(Calendar.current.standaloneMonthSymbols[overview.month - 1])"
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { self.viewModel.isAddNewTransactionPresented = true }) {
                    Label("New transaction", systemImage: "plus")
                }
            }
        })
    }

    // MARK: Private builder methods - Transactions

    @ViewBuilder private func makeTransactionsListView() -> some View {
        let year = viewModel.yearlyOverview.year
        let transactions = viewModel.yearlyOverview.expenses
        let viewModel = TransactionsListViewModel(transactions: transactions, dataProvider: viewModel)

        TransactionsListView(
            viewModel: viewModel,
            addNewTransaction: { self.viewModel.isAddNewTransactionPresented = true }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DefaultToolbar(
                    title: "Transactions \(self.viewModel.yearlyOverview.name)",
                    subtitle: String(year)
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { self.viewModel.isAddNewTransactionPresented = true }) {
                    Label("New transaction", systemImage: "plus")
                }
            }
        }
    }
}

struct YearlyOverviewView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        YearlyOverviewView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
