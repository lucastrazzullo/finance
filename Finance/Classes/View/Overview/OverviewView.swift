//
//  OverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewView: View {

    let title: String
    let subtitle: String
    let favouriteBudgetOverviews: [MonthlyBudgetOverview]
    let lowestBudgetOverviews: [MonthlyBudgetOverview]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Favourites")) {
                    ForEach(favouriteBudgetOverviews, id: \.self) { overview in
                        MonthlyBudgetOverviewItem(overview: overview)
                            .listRowSeparator(.hidden)
                    }
                }

                Section(header: Text("Lowest budgets this month")) {
                    ForEach(lowestBudgetOverviews, id: \.self) { overview in
                        MonthlyBudgetOverviewItem(overview: overview)
                            .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                DefaultToolbar(
                    title: title,
                    subtitle: subtitle
                )
            })
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(
            title: "Title",
            subtitle: "Subtitle",
            favouriteBudgetOverviews: Mocks.monthlyOverviews,
            lowestBudgetOverviews: Mocks.montlyExpiringOverviews
        )
    }
}
