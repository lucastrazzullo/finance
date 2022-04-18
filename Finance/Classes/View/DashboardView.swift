//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    let overview: YearlyBudgetOverview
    let addTransactions: ([Transaction]) async throws -> Void
    let addBudget: (Budget) async throws -> Void
    let deleteBudgets: (Set<Budget.ID>) async throws -> Void
    let addSliceToBudget: (BudgetSlice, Budget.ID) async throws -> Void
    let deleteSlices: (Set<BudgetSlice.ID>, Budget.ID) async throws -> Void
    let updateNameAndIcon: (String, SystemIcon, Budget.ID) async throws -> Void

    var body: some View {
        TabView {
            OverviewListView(
                overview: overview,
                addTransactions: addTransactions
            )
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            BudgetsListView(
                year: overview.year,
                name: overview.name,
                budgets: overview.budgets,
                addBudget: addBudget,
                deleteBudgets: deleteBudgets,
                addSliceToBudget: addSliceToBudget,
                deleteSlices: deleteSlices,
                updateNameAndIcon: updateNameAndIcon
            )
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            overview: Mocks.overview,
            addTransactions: { _ in },
            addBudget: { _ in },
            deleteBudgets: { _ in },
            addSliceToBudget: { _, _ in },
            deleteSlices: { _, _ in },
            updateNameAndIcon: { _, _, _  in }
        )
    }
}
