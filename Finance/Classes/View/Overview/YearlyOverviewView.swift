//
//  YearlyOverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct YearlyOverviewView: View {

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: .now)

    let overview: YearlyBudgetOverview

    var allOverviews: [MonthlyBudgetOverview] {
        return overview
            .budgets
            .map(\.id)
            .compactMap({ overview.monthlyOverview(month: selectedMonth, forBudgetWith: $0) })
    }

    var lowestBudgetAvailabilityOverviews: [MonthlyBudgetOverview] {
        return overview
            .budgets
            .map(\.id)
            .compactMap({ overview.monthlyOverview(month: selectedMonth, forBudgetWith: $0) })
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    var body: some View {
        NavigationView {
            List {
                if allOverviews.count > 0 {
                    Section(header: Text("All Overviews")) {
                        ForEach(allOverviews, id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                if lowestBudgetAvailabilityOverviews.count > 0 {
                    Section(header: Text("Lowest budgets this month")) {
                        ForEach(lowestBudgetAvailabilityOverviews, id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    DefaultToolbar(
                        title: overview.name,
                        subtitle: "Overview \(String(overview.year))"
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    MonthPickerView(month: $selectedMonth)
                        .pickerStyle(MenuPickerStyle())
                }
            })
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    let overview = Mocks.overview
    static var previews: some View {
        YearlyOverviewView(overview: try! .init(name: "Amsterdam", year: 2022, budgets: [], transactions: []))
    }
}
