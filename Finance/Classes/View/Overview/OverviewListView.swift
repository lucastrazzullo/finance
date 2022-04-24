//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView<Header: ToolbarContent>: View {

    @ObservedObject var viewModel: OverviewListViewModel
    @ToolbarContentBuilder var header: () -> Header

    var body: some View {
        NavigationView {
            List {
                let montlhyOverviews = viewModel.monthlyOverviews
                if montlhyOverviews.count > 0 {
                    Section(header: Text("All Overviews")) {
                        ForEach(montlhyOverviews, id: \.self) { overview in
                            NavigationLink(destination: makeTransactionListView(overview: overview)) {
                                MonthlyBudgetOverviewItem(overview: overview)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }

                let monthlyOverviewsWithLowestAvailability = viewModel.monthlyOverviewsWithLowestAvailability
                if monthlyOverviewsWithLowestAvailability.count > 0 {
                    Section(header: Text("Lowest budgets this month")) {
                        ForEach(monthlyOverviewsWithLowestAvailability, id: \.self) { overview in
                            NavigationLink(destination: makeTransactionListView(overview: overview)) {
                                MonthlyBudgetOverviewItem(overview: overview)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                header()

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
            .sheet(isPresented: $viewModel.addNewTransactionIsPresented) {
                AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(expenses:))
            }
        }
    }

    // MARK: Private builder methods

    @ViewBuilder private func makeTransactionListView(overview: MonthlyBudgetOverview) -> some View {
        TransactionsListView(transactions: overview.expensesInMonth)
            .navigationTitle("Expenses \(overview.name)")
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewListView(
            viewModel: .init(
                yearlyOverview: .init(
                    name: "Mock",
                    year: Mocks.year,
                    budgets: Mocks.budgets,
                    expenses: Mocks.transactions
                ),
                storageProvider: MockStorageProvider(),
                delegate: nil
            ),
            header: {
                ToolbarItem {
                    Text("Header")
                }
            }
        )
    }
}
