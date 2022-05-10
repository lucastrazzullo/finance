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

    @State private var month: Int = Calendar.current.component(.month, from: .now)

    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .leading) {
                    makeIncomeOverviewView()
                    makeMonthlyOverviewsListView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: { makeToolbar(titlePrefix: "Overview", showsMenuPicker: true) })
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Budgets", showsMenuPicker: false) })
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView(transactions: viewModel.yearlyOverview.expenses)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Transactions", showsMenuPicker: false) })
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

    @ViewBuilder private func makeIncomeOverviewView() -> some View {
        VStack {
            Text("Income")
                .font(.headline)
                .foregroundColor(.gray)

            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: 100)
                    .foregroundColor(.green)
            }
            .frame(height: 24)
            .cornerRadius(12)
        }
        .padding()
    }

    @ViewBuilder private func makeMonthlyOverviewsListView() -> some View {
        MontlyOverviewsListView(
            monthlyOverviews: viewModel.yearlyOverview.monthlyOverviews(month: month),
            monthlyOverviewsWithLowestAvailability: viewModel.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month),
            item: { monthlyOverview in
                NavigationLink(
                    destination: {
                        TransactionsListView(
                            viewModel: TransactionsListViewModel(
                                transactions: monthlyOverview.expensesInMonth,
                                addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                                deleteTransactions: viewModel.delete(transactionsWith:)
                            )
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

    @ToolbarContentBuilder private func makeToolbar(titlePrefix: String, showsMenuPicker: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            let title = "\(titlePrefix) \(viewModel.yearlyOverview.name)"
            let year = String(viewModel.yearlyOverview.year)
            let month = showsMenuPicker ? Calendar.current.shortMonthSymbols[month - 1] : nil

            VStack {
                Text(title).font(.title2.bold())

                HStack(spacing: 6) {
                    Text(year).font(.caption)

                    if let month = month {
                        Text("›")
                        Text(month).font(.caption.bold())
                    }
                }
            }
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

struct YearlyOverviewView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        FinanceView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
