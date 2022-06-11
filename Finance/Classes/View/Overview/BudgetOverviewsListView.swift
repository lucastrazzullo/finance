//
//  BudgetOverviewsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetOverviewsListView<Item: View>: View {

    private let maximumNumberOfOverviews: Int = 3

    let budgetOverviews: [BudgetOverview]
    let budgetOverviewsWithLowestAvailability: [BudgetOverview]

    @ViewBuilder var item: (BudgetOverview) -> Item

    @State private var showAllOverviews: Bool = false

    var body: some View {
        List {
            if budgetOverviews.count > 0 {
                Section(header: Text("Overviews")) {
                    if showAllOverviews {
                        ForEach(budgetOverviews) { overview in
                            item(overview)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        ForEach(budgetOverviews[0..<min(maximumNumberOfOverviews, budgetOverviews.count)]) { overview in
                            item(overview)
                                .listRowSeparator(.hidden)
                        }
                    }

                    if budgetOverviews.count > maximumNumberOfOverviews && !budgetOverviewsWithLowestAvailability.isEmpty {
                        Button(action: { showAllOverviews.toggle() }) {
                            Label(
                                showAllOverviews ? "Show less" : "Show more",
                                systemImage: showAllOverviews ? "chevron.up" : "chevron.down"
                            )
                        }
                    }
                }
            }

            if budgetOverviewsWithLowestAvailability.count > 0 {
                Section(header: Text("Lowest budgets this month")) {
                    ForEach(budgetOverviewsWithLowestAvailability) { overview in
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
            budgetOverviews: Mocks.yearlyOverview.budgetOverviews(month: 1),
            budgetOverviewsWithLowestAvailability: Mocks.yearlyOverview.budgetOverviews(month: 1),
            item: { overview in
                BudgetOverviewItem(overview: overview)
            }
        )
    }
}
