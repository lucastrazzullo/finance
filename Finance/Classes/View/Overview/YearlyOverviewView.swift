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
                makeMonthlyOverviewsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Overview", showsMenuPicker: true) })
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Budgets", showsMenuPicker: false) })
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.YearlyOverviewView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView(transactions: viewModel.yearlyOverview.expenses)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Transactions", showsMenuPicker: false) })
            }
            .tabItem {
                Label("Transactions", systemImage: "arrow.left.arrow.right.square")
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

    // MARK: Private builder methods - Tabs

    @ViewBuilder private func makeMonthlyOverviewsListView() -> some View {
        MontlyOverviewsListView(
            montlhyOverviews: viewModel.yearlyOverview.monthlyOverviews(month: month),
            monthlyOverviewsWithLowestAvailability: viewModel.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month),
            item: { monthlyOverview in
                NavigationLink(
                    destination: {
                        TransactionsListView(
                            viewModel: TransactionsListViewModel(
                                transactions: monthlyOverview.expensesInMonth,
                                dataProvider: viewModel
                            ),
                            addNewTransaction: {
                                self.viewModel.isAddNewTransactionPresented = true
                            }
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(content: { makeToolbar(titlePrefix: "Expenses", showsMenuPicker: true) })
                    },
                    label: {
                        MonthlyOverviewItem(overview: monthlyOverview)
                    }
                )
            }
        )
    }

    @ViewBuilder private func makeBudgetsListView() -> some View {
        BudgetsListView(
            viewModel: BudgetsListViewModel(
                budgets: viewModel.yearlyOverview.budgets,
                dataProvider: viewModel
            ),
            item: { budget in
                NavigationLink(
                    destination: BudgetView(
                        viewModel: BudgetViewModel(budget: budget, dataProvider: viewModel)
                    ),
                    label: {
                        BudgetsListItem(budget: budget)
                    }
                )
            },
            addNewBudget: { self.viewModel.isAddNewBudgetPresented = true }
        )
    }

    @ViewBuilder private func makeTransactionsListView(transactions: [Transaction]) -> some View {
        TransactionsListView(
            viewModel: TransactionsListViewModel(
                transactions: transactions,
                dataProvider: viewModel
            ),
            addNewTransaction: { self.viewModel.isAddNewTransactionPresented = true }
        )
    }

    // MARK: Private builder methods - Toolbar

    @ToolbarContentBuilder private func makeToolbar(titlePrefix: String, showsMenuPicker: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            let title = "\(titlePrefix) \(viewModel.yearlyOverview.name)"
            let subtitle = showsMenuPicker
                ? String(viewModel.yearlyOverview.year) + " / " + Calendar.current.shortMonthSymbols[month - 1]
                : String(viewModel.yearlyOverview.year)

            DefaultToolbar(
                title: title,
                subtitle: subtitle
            )
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                if showsMenuPicker {
                    MonthPickerView(month: $month)
                        .pickerStyle(MenuPickerStyle())
                }

                Button(action: { viewModel.isAddNewTransactionPresented = true }) {
                    Label("New transaction", systemImage: "plus")
                }

                Button(action: { self.viewModel.isAddNewBudgetPresented = true }) {
                    Label("New budget", systemImage: "plus")
                }
            }
            label: {
                Label("Options", systemImage: "ellipsis.circle")
            }
        }
    }
}

// MARK: - Previews

private struct YearlyOverviewView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        YearlyOverviewView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
