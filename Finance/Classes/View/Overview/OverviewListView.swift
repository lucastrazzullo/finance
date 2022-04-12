//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView: View {

    private var overviewsWithLowestAvailability: [MonthlyBudgetOverview] {
        overviews
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    @Binding var month: Int

    let title: String
    let subtitle: String
    let overviews: [MonthlyBudgetOverview]

    let onAppear: () async -> Void
    let onAdd: () -> Void

    var body: some View {
        NavigationView {
            List {
                if overviews.count > 0 {
                    Section(header: Text("All Overviews")) {
                        ForEach(overviews, id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                if overviewsWithLowestAvailability.count > 0 {
                    Section(header: Text("Lowest budgets this month")) {
                        ForEach(overviewsWithLowestAvailability, id: \.self) { overview in
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
                        title: title,
                        subtitle: subtitle
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onAdd) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
            .onAppear(perform: { Task { await onAppear() }})
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    let overview = Mocks.overview
    static var previews: some View {
        OverviewListView(
            month: .constant(1),
            title: "Amsterdam",
            subtitle: "2022",
            overviews: Mocks.overview.monthlyOverviews(month: 1),
            onAppear: {},
            onAdd: {}
        )
    }
}
