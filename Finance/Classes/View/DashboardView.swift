//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    @ObservedObject private var reportController: ReportController

    @State private var isAddNewBudgetPresented: Bool = false
    @State private var deleteBudgetsError: DomainError?

    private let storageProvider: StorageProviderType

    var body: some View {
        TabView {
            NavigationView {
                OverviewView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: makeToolbarPrimaryItem)
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
            }

            NavigationView {
                BudgetsListView(
                    listItem: { budget in
                        let destination = BudgetView(budget: budget, storageProvider: storageProvider)
                        NavigationLink(destination: destination) {
                            AmountListItem(label: budget.name, amount: budget.amount)
                        }
                    },
                    budgets: reportController.report.budgets,
                    error: deleteBudgetsError,
                    onAdd: { isAddNewBudgetPresented = true },
                    onDelete: deleteBudgets(at:)
                )
                .onAppear {
                    Task {
                        try? await reportController.fetch()
                    }
                }
                .sheet(isPresented: $isAddNewBudgetPresented) {
                    NewBudgetView { budget in
                        try await reportController.add(budget: budget)
                        isAddNewBudgetPresented = false
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: EditButton())
                .toolbar(content: makeToolbarPrimaryItem)
            }
            .tabItem {
                Label("Budgets", systemImage: "list.dash")
            }
        }
    }

    // MARK: Private helper methods

    private func deleteBudgets(at indices: IndexSet) {
        Task {
            do {
                try await reportController.delete(budgetsAt: indices)
                deleteBudgetsError = nil
            } catch {
                deleteBudgetsError = error as? DomainError
            }
        }
    }

    // MARK: Object life cycle

    init(storageProvider: StorageProviderType) {
        self.storageProvider = storageProvider
        self.reportController = ReportController(report: Report.current(with: []), storageProvider: storageProvider)
    }

    func makeToolbarPrimaryItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            VStack(alignment: .leading) {
                Text(reportController.report.name).font(.title2.bold())
                Text("Overview \(String(reportController.report.year))").font(.caption)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(storageProvider: MockStorageProvider())
    }
}
