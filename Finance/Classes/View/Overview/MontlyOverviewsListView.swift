//
//  MontlyOverviewsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct MontlyOverviewsListView<Item: View>: View {

    let montlhyOverviews: [MonthlyBudgetOverview]
    let monthlyOverviewsWithLowestAvailability: [MonthlyBudgetOverview]

    @ViewBuilder var item: (MonthlyBudgetOverview) -> Item

    var body: some View {
        List {
            if montlhyOverviews.count > 0 {
                Section(header: Text("All Overviews")) {
                    ForEach(montlhyOverviews, id: \.self) { overview in
                        item(overview)
                            .listRowSeparator(.hidden)
                    }
                }
            }

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
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MontlyOverviewsListView(
            montlhyOverviews: Mocks.overview.monthlyOverviews(month: 1),
            monthlyOverviewsWithLowestAvailability: Mocks.overview.monthlyOverviewsWithLowestAvailability(month: 1),
            item: { overview in
                MonthlyOverviewItem(overview: overview)
            }
        )
    }
}
