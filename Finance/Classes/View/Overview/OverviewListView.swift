//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView<Item: View>: View {

    let month: Int
    let yearlyOverview: YearlyBudgetOverview

    @ViewBuilder var item: (MonthlyBudgetOverview) -> Item

    var body: some View {
        List {
            let montlhyOverviews = yearlyOverview.monthlyOverviews(month: month)
            if montlhyOverviews.count > 0 {
                Section(header: Text("All Overviews")) {
                    ForEach(montlhyOverviews, id: \.self) { overview in
                        item(overview)
                            .listRowSeparator(.hidden)
                    }
                }
            }

            let monthlyOverviewsWithLowestAvailability = yearlyOverview.monthlyOverviewsWithLowestAvailability(month: month)
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
        OverviewListView(
            month: Calendar.current.component(.month, from: .now),
            yearlyOverview: Mocks.overview,
            item: { overview in
                MonthlyBudgetOverviewItem(overview: overview)
            }
        )
    }
}
