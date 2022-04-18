//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView: View {

    @State private var month: Int = Calendar.current.component(.month, from: .now)
    @State private var addNewTransactionIsPresented: Bool = false

    let overview: YearlyBudgetOverview
    let addTransactions: ([Transaction]) async throws -> Void

    var body: some View {
        NavigationView {
            List {
                let montlhyOverviews = overview.monthlyOverviews(month: month)
                if montlhyOverviews.count > 0 {
                    Section(header: Text("All Overviews")) {
                        ForEach(montlhyOverviews, id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                let monthlyOverviewsWithLowestAvailability = overview.monthlyOverviewsWithLowestAvailability(month: month)
                if monthlyOverviewsWithLowestAvailability.count > 0 {
                    Section(header: Text("Lowest budgets this month")) {
                        ForEach(monthlyOverviewsWithLowestAvailability, id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    MonthPickerView(month: $month)
                        .pickerStyle(MenuPickerStyle())
                }

                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: String(overview.year),
                        subtitle: overview.name
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
            .sheet(isPresented: $addNewTransactionIsPresented) {
                AddTransactionsView(budgets: overview.budgets, onSubmit: add(transactions:))
            }
        }
    }

    // MARK: Private helper methods

    private func add(transactions: [Transaction]) async throws {
        try await addTransactions(transactions)
        addNewTransactionIsPresented = false
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewListView(overview: Mocks.overview, addTransactions: { _ in })
    }
}
