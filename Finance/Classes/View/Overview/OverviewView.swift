//
//  OverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewView<ListItem: View, ViewAllDestination: View>: View {

    @ViewBuilder let listItem: (MonthlyBudgetOverview) -> ListItem
    @ViewBuilder let viewAllDestination: () -> ViewAllDestination

    let mostViewedOverviews: [MonthlyBudgetOverview]
    let lowestBudgetOverviews: [MonthlyBudgetOverview]

    var body: some View {
        List {
            Section(header: Text("Most viewed in April")) {
                ForEach(mostViewedOverviews, id: \.self) { overview in
                    listItem(overview).listRowSeparator(.hidden)
                }

                NavigationLink(destination: viewAllDestination()) {
                    Text("View all")
                }
            }

            Section(header: Text("Lowest budgets in April")) {
                ForEach(lowestBudgetOverviews, id: \.self) { overview in
                    listItem(overview).listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(
            listItem: { overview in MonthlyBudgetOverviewItem(overview: overview) },
            viewAllDestination: { EmptyView() },
            mostViewedOverviews: Mocks.monthlyOverviews,
            lowestBudgetOverviews: Mocks.montlyExpiringOverviews
        )
    }
}
