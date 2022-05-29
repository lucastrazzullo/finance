//
//  FinanceView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct FinanceView: View {

    @Environment(\.storageProvider) private var storageProvider

    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .center, spacing: 0) {
                    makeMonthlyProspectView()
                    makeMonthlyOverviewsListView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    makeToolbar(titlePrefix: "Overview", showsMonthPicker: true, showsMonth: false)
                }
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        makeToolbar(titlePrefix: "Budgets", showsMonthPicker: false, showsMonth: false)
                    }
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView(transactions: viewModel.yearlyOverview.transactions)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        makeToolbar(titlePrefix: "Transactions", showsMonthPicker: false, showsMonth: false)
                    }
            }
            .tabItem {
                Label("Transactions", systemImage: "arrow.left.arrow.right.square")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.transactionsTab)
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

    @ViewBuilder private func makeMonthlyProspectView() -> some View {
        if viewModel.monthlyProspects.isEmpty {
            EmptyView()
        } else {
            MonthlyProspectsListView(
                selectedMonth: $viewModel.selectedMonth,
                prospects: viewModel.monthlyProspects
            )
        }
    }

    @ViewBuilder private func makeMonthlyOverviewsListView() -> some View {
        MontlyOverviewsListView(
            monthlyOverviews: viewModel.monthlyOverviews,
            monthlyOverviewsWithLowestAvailability: viewModel.monthlyOverviewsWithLowestAvailability,
            item: { monthlyOverview in
                NavigationLink(
                    destination: {
                        TransactionsListView(
                            viewModel: TransactionsListViewModel(
                                transactions: monthlyOverview.transactionsInMonth,
                                addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                                deleteTransactions: viewModel.delete(transactionsWith:)
                            )
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            makeToolbar(titlePrefix: "Expenses", showsMonthPicker: true, showsMonth: true)
                        }
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
                addBudgets: { self.viewModel.isAddNewBudgetPresented = true },
                deleteBudgets: viewModel.delete(budgetsWith:)
            ),
            item: { budget in
                NavigationLink(
                    destination: BudgetView(
                        viewModel: BudgetViewModel(budget: budget, storageHandler: viewModel)
                    ),
                    label: {
                        BudgetsListItem(budget: budget)
                    }
                )
            }
        )
    }

    @ViewBuilder private func makeTransactionsListView(transactions: [Transaction]) -> some View {
        TransactionsListView(
            viewModel: TransactionsListViewModel(
                transactions: transactions,
                addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                deleteTransactions: viewModel.delete(transactionsWith:)
            )
        )
    }

    // MARK: Private builder methods - Toolbar

    @ToolbarContentBuilder private func makeToolbar(titlePrefix: String, showsMonthPicker: Bool, showsMonth: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            let title = "\(titlePrefix) \(viewModel.yearlyOverview.name)"
            let year = String(viewModel.yearlyOverview.year)

            VStack {
                Text(title).font(.title2.bold())

                HStack(spacing: 6) {
                    Text(year).font(.caption)

                    if showsMonth {
                        Text("›")
                        Text(viewModel.month).font(.caption.bold())
                    }
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                if showsMonthPicker {
                    MonthPickerView(month: $viewModel.selectedMonth)
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

struct FinanceView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.expenseBudgets, transactions: Mocks.allTransactions)
    static var previews: some View {
        FinanceView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
//            .preferredColorScheme(.dark)
            .environment(\.storageProvider, storageProvider)
    }
}
