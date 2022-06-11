//
//  FinanceView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct FinanceView: View {

    @ObservedObject var finance: Finance
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .leading) {
                    BalanceOverviewView(currentBalance: viewModel.currentBalance)
                    BudgetOverviewsView(
                        itemBuilder: { budgetOverview in
                            NavigationLink(
                                destination: {
                                    TransactionsListView(
                                        viewModel: TransactionsListViewModel(
                                            transactions: budgetOverview.transactionsInMonth,
                                            addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                                            deleteTransactions: viewModel.delete(transactionsWith:)
                                        )
                                    )
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        makeToolbar(
                                            title: "Transactions \(budgetOverview.name)",
                                            subtitle: "\(viewModel.yearlyOverview.year) / \(viewModel.month)",
                                            showsMonthPicker: true
                                        )
                                    }
                                },
                                label: {
                                    BudgetOverviewItem(overview: budgetOverview)
                                }
                            )
                        },
                        budgetOverviews: viewModel.budgetOverviews
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    makeToolbar(
                        title: "Overview \(viewModel.yearlyOverview.name)",
                        subtitle: "\(viewModel.yearlyOverview.year) / \(viewModel.month)",
                        showsMonthPicker: true
                    )
                }
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.overviewTab)
            }

            NavigationView {
                BudgetsListView(
                    itemBuilder: { budget in
                        NavigationLink(
                            destination: BudgetView(
                                viewModel: BudgetViewModel(budget: budget, storageHandler: finance)
                            ),
                            label: {
                                BudgetsListItem(budget: budget)
                            }
                        )
                    },
                    viewModel: BudgetsListViewModel(
                        budgets: viewModel.yearlyOverview.budgets,
                        addBudgets: { self.viewModel.isAddNewBudgetPresented = true },
                        deleteBudgets: viewModel.delete(budgetsWith:)
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    makeToolbar(
                        title: "Budgets \(viewModel.yearlyOverview.name)",
                        subtitle: "\(viewModel.yearlyOverview.year)",
                        showsMonthPicker: false
                    )
                }
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.budgetsTab)
            }

            NavigationView {
                TransactionsListView(
                    viewModel: TransactionsListViewModel(
                        transactions: viewModel.yearlyOverview.transactions,
                        addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                        deleteTransactions: viewModel.delete(transactionsWith:)
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    makeToolbar(
                        title: "Transactions \(viewModel.yearlyOverview.name)",
                        subtitle: "\(viewModel.yearlyOverview.year)",
                        showsMonthPicker: false
                    )
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

    // MARK: Private builder methods - Toolbar

    @ToolbarContentBuilder private func makeToolbar(title: String, subtitle: String?, showsMonthPicker: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            VStack {
                Text(title).font(.title2.bold())

                if let subtitle = subtitle {
                    Text(subtitle).font(.caption)
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

    // MARK: Object life cycle

    init(finance: Finance, year: Int) {
        self.finance = finance
        self.viewModel = FinanceViewModel(
            year: year,
            openingBalance: .zero,
            storageHandler: finance
        )
    }
}

// MARK: - Views

private struct BudgetOverviewsView<Item: View>: View {

    @ViewBuilder let itemBuilder: (BudgetOverview) -> Item

    let budgetOverviews: [BudgetOverview]

    var body: some View {
        BudgetOverviewsListView(
            budgetOverviews: budgetOverviews,
            budgetOverviewsWithLowestAvailability: budgetOverviewsWithLowestAvailability,
            item: { budgetOverview in itemBuilder(budgetOverview) }
        )
    }

    private var budgetOverviewsWithLowestAvailability: [BudgetOverview] {
        budgetOverviews
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }
}

// MARK: - Previews

struct FinanceView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.expenseBudgets, transactions: Mocks.allTransactions)
    static let finance = Finance(storageProvider: storageProvider)
    static var previews: some View {
        FinanceView(finance: finance, year: Mocks.year)
//            .preferredColorScheme(.dark)
    }
}
