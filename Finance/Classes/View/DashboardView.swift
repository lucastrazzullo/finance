//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    @ObservedObject private var overviewController: OverviewController

    @State private var isAddNewBudgetPresented: Bool = false
    @State private var deleteBudgetsError: DomainError?

    private let storageProvider: StorageProviderType

    var body: some View {
        TabView {
            OverviewView(
                title: overviewController.overview.name,
                subtitle: "Overview \(String(overviewController.overview.year))",
                favouriteBudgetOverviews: Mocks.monthlyOverviews,
                lowestBudgetOverviews: Mocks.montlyExpiringOverviews
            )
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            BudgetsListView(
                destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
                title: overviewController.overview.name,
                subtitle: "Budgets \(String(overviewController.overview.year))",
                budgets: overviewController.overview.budgets,
                error: deleteBudgetsError,
                onAdd: { isAddNewBudgetPresented = true },
                onDelete: deleteBudgets(at:)
            )
            .onAppear {
                Task {
                    try? await overviewController.fetch()
                }
            }
            .sheet(isPresented: $isAddNewBudgetPresented) {
                NewBudgetView(year: overviewController.overview.year) { budget in
                    try await overviewController.add(budget: budget)
                    isAddNewBudgetPresented = false
                }
            }
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
    }

    // MARK: Private helper methods

    private func deleteBudgets(at indices: IndexSet) {
        Task {
            do {
                try await overviewController.delete(budgetsAt: indices)
                deleteBudgetsError = nil
            } catch {
                deleteBudgetsError = error as? DomainError
            }
        }
    }

    // MARK: Object life cycle

    init(storageProvider: StorageProviderType) {
        self.storageProvider = storageProvider
        self.overviewController = OverviewController(overview: YearlyBudgetOverview.current(with: []), storageProvider: storageProvider)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(storageProvider: MockStorageProvider(overviewYear: 2022))
    }
}
