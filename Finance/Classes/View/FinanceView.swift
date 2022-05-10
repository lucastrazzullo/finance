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
                VStack(alignment: .leading) {
                    makeIncomeOverviewView()
                    makeMonthPrediction()
                    makeMonthlyOverviewsListView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: { makeToolbar(titlePrefix: "Overview", showsMonthPicker: true) })
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Budgets", showsMonthPicker: false) })
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView(transactions: viewModel.yearlyOverview.expenses)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Transactions", showsMonthPicker: false) })
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
                .foregroundColor(.secondary)

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

    @ViewBuilder private func makeMonthPrediction() -> some View {
        VStack {
            Text(viewModel.month)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: 100, height: 40)

                ZStack {
                    Rectangle()
                        .foregroundColor(.green)
                        .frame(width: 100, height: 50)

                    Rectangle()
                        .frame(width: 110, height: 2)
                }

                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 100, height: 30)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder private func makeMonthlyOverviewsListView() -> some View {
        MontlyOverviewsListView(
            monthlyOverviews: viewModel.yearlyOverview.monthlyOverviews(month: viewModel.selectedMonth),
            monthlyOverviewsWithLowestAvailability: viewModel.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: viewModel.selectedMonth),
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
                        .toolbar(content: { makeToolbar(titlePrefix: "Expenses", showsMonthPicker: true) })
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

    @ToolbarContentBuilder private func makeToolbar(titlePrefix: String, showsMonthPicker: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            let title = "\(titlePrefix) \(viewModel.yearlyOverview.name)"
            let year = String(viewModel.yearlyOverview.year)

            VStack {
                Text(title).font(.title2.bold())

                HStack(spacing: 6) {
                    Text(year).font(.caption)

                    if showsMonthPicker {
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
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        FinanceView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
            .environment(\.storageProvider, storageProvider)
    }
}
