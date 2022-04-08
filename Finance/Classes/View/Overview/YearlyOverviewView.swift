//
//  YearlyOverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct YearlyOverviewView: View {

    let overview: YearlyBudgetOverview

    var favouriteBudgetOverviews: [MonthlyBudgetOverview] {
        Mocks.monthlyFavouriteOverviews
    }

    var lowestBudgetOverviews: [MonthlyBudgetOverview] {
        Mocks.montlyExpiringOverviews
    }

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
                    title: overview.name,
                    subtitle: "Overview \(String(overview.year))"
                )
            })
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    let overview = try! YearlyBudgetOverview(name: "Amsterdam", year: 2022, budgets: Mocks.budgets(withYear: 2022))
    static var previews: some View {
        YearlyOverviewView(overview: try! .init(name: "Amsterdam", year: 2022, budgets: []))
    }
}
