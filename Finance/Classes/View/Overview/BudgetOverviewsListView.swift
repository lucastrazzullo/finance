//
//  BudgetOverviewsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetOverviewsListView<Item: View>: View {

    private let maximumNumberOfOverviews: Int = 3

    let monthlyOverviews: [BudgetOverview]
    let monthlyOverviewsWithLowestAvailability: [BudgetOverview]

    @ViewBuilder var item: (BudgetOverview) -> Item

    @State private var showAllOverviews: Bool = false

    var body: some View {
        List {
            if monthlyOverviews.count > 0 {
                Section(header: Text("Overviews")) {
                    if showAllOverviews {
                        ForEach(monthlyOverviews) { overview in
                            item(overview)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        ForEach(monthlyOverviews[0..<min(maximumNumberOfOverviews, monthlyOverviews.count)]) { overview in
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
                    ForEach(monthlyOverviewsWithLowestAvailability) { overview in
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
        BudgetOverviewsListView(
            monthlyOverviews: Mocks.yearlyOverview.budgetOverviews(month: 1),
            monthlyOverviewsWithLowestAvailability: Mocks.yearlyOverview.budgetOverviews(month: 1),
            item: { overview in
                BudgetOverviewItem(overview: overview)
            }
        )
    }
}
