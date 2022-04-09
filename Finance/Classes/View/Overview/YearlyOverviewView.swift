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

    var favouriteBudgetOverviews: [MonthlyBudgetOverview] {
        guard overview.budgets.count > 1 else {
            return []
        }
        return overview.budgets[0...1]
            .map(\.id)
            .compactMap { identifier -> MonthlyBudgetOverview? in
                return overview.monthlyOverview(month: selectedMonth, forBudgetWith: identifier)
            }
    }

    var lowestBudgetAvailabilityOverviews: [MonthlyBudgetOverview] {
        Mocks.randomBudgetIdentifiers(count: 3)
            .compactMap { identifier in
                guard let budget = Mocks.overview.budget(with: identifier) else {
                    return nil
                }

                return MonthlyBudgetOverview(
                    name: budget.name,
                    icon: budget.icon,
                    startingAmount: .value(1000),
                    totalExpenses: .value(900)
                )
            }
    }

    var body: some View {
        NavigationView {
            List {
                if favouriteBudgetOverviews.count > 0 {
                    Section(header: Text("Favourites")) {
                        ForEach(favouriteBudgetOverviews, id: \.self) { overview in
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
        YearlyOverviewView(overview: try! .init(name: "Amsterdam", year: 2022, budgets: []))
    }
}
