//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView<Item: View>: View {

    @ObservedObject var viewModel: OverviewListViewModel

    @ViewBuilder var item: (MonthlyBudgetOverview) -> Item

    var body: some View {
        List {
            let montlhyOverviews = viewModel.monthlyOverviews
            if montlhyOverviews.count > 0 {
                Section(header: Text("All Overviews")) {
                    ForEach(montlhyOverviews, id: \.self) { overview in
                        item(overview)
                            .listRowSeparator(.hidden)
                    }
                }
            }

            let monthlyOverviewsWithLowestAvailability = viewModel.monthlyOverviewsWithLowestAvailability
            if monthlyOverviewsWithLowestAvailability.count > 0 {
                Section(header: Text("Lowest budgets this month")) {
                    ForEach(monthlyOverviewsWithLowestAvailability, id: \.self) { overview in
                        item(overview)
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $viewModel.addNewTransactionIsPresented) {
            AddTransactionsView(budgets: viewModel.budgets, onSubmit: viewModel.add(expenses:))
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewListView(
            viewModel: .init(
                month: Calendar.current.component(.month, from: .now),
                yearlyOverview: .init(
                    name: "Mock",
                    year: Mocks.year,
                    budgets: Mocks.budgets,
                    expenses: Mocks.transactions
                ),
                storageProvider: MockStorageProvider(),
                delegate: nil
            ),
            item: { overview in
                MonthlyBudgetOverviewItem(overview: overview)
            }
        )
    }
}
