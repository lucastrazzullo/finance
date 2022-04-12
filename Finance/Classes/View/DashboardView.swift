//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    @ObservedObject private var overviewController: OverviewController

    @State private var selectedMonth: Int = Calendar.current.component(.month, from: .now)

    @State private var addNewBudgetForOverview: YearlyBudgetOverview?
    @State private var deleteBudgetsError: DomainError?

    @State private var addNewTransactionForOverview: YearlyBudgetOverview?

    private let storageProvider: StorageProviderType

    var body: some View {
        TabView {
            ZStack {
                if let overview = overviewController.overview {
                    OverviewListView(
                        month: $selectedMonth,
                        title: overview.name,
                        subtitle: "Overview \(String(overview.year))",
                        overviews: overview.monthlyOverviews(month: selectedMonth),
                        onAppear: { try? await overviewController.fetch() },
                        onAdd: { addNewTransactionForOverview = overviewController.overview }
                    )
                } else {
                    Text("Fetching ...")
                }
            }
            .sheet(item: $addNewTransactionForOverview) { overview in
                NewTransactionView(budgets: overview.budgets) { transaction in
                    overviewController.add(transaction: transaction)
                    addNewTransactionForOverview = nil
                }
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            ZStack {
                if let overview = overviewController.overview {
                    BudgetsListView(
                        destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
                        title: overview.name,
                        subtitle: "Budgets \(String(Mocks.overview.year))",
                        budgets: overview.budgets,
                        error: deleteBudgetsError,
                        onAppear: { try? await overviewController.fetch() },
                        onAdd: { addNewBudgetForOverview = overviewController.overview },
                        onDelete: deleteBudgets(at:)
                    )
                } else {
                    Text("Fetching ...")
                }
            }
            .sheet(item: $addNewBudgetForOverview) { overview in
                NewBudgetView(year: overview.year) { budget in
                    try await overviewController.add(budget: budget)
                    addNewBudgetForOverview = nil
                }
            }
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsTab)
            }
        }
        .onAppear {
            Task {
                try? await overviewController.fetch()
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

    init(overviewYear: Int, storageProvider: StorageProviderType) {
        self.storageProvider = storageProvider
        self.overviewController = OverviewController(overviewYear: overviewYear, storageProvider: storageProvider)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static let year: Int = 2022
    static var previews: some View {
        DashboardView(overviewYear: year, storageProvider: MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions))
    }
}
