//
//  MontlyOverviewsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct MontlyOverviewsListView<Item: View>: View {

    private let maximumNumberOfOverviews: Int = 3

    let monthlyOverviews: [MonthlyBudgetOverview]
    let monthlyOverviewsWithLowestAvailability: [MonthlyBudgetOverview]

    @ViewBuilder var item: (MonthlyBudgetOverview) -> Item

    @State private var showAllOverviews: Bool = false

    var body: some View {
        List {
            if monthlyOverviews.count > 0 {
                Section(header: Text("Monthly Overviews")) {
                    if showAllOverviews {
                        ForEach(monthlyOverviews, id: \.self) { overview in
                            item(overview)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        ForEach(monthlyOverviews[0..<min(maximumNumberOfOverviews, monthlyOverviews.count)], id: \.self) { overview in
                            item(overview)
                                .listRowSeparator(.hidden)
                        }
                    }

                    if monthlyOverviews.count > maximumNumberOfOverviews {
                        Button(action: { showAllOverviews.toggle() }) {
                            Label(
                                showAllOverviews ? "Show less" : "Show more",
                                systemImage: showAllOverviews ? "chevron.up" : "chevron.down"
                            )
                        }
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
            monthlyOverviews: Mocks.yearlyOverview.monthlyOverviews(month: 1),
            monthlyOverviewsWithLowestAvailability: Mocks.yearlyOverview.monthlyOverviewsWithLowestAvailability(month: 1),
            item: { overview in
                MonthlyOverviewItem(overview: overview)
            }
        )
    }
}
