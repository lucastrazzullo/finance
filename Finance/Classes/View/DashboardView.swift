//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    private let storageProvider: StorageProviderType

    @ObservedObject private var reportController: ReportController

    @State private var isAddNewBudgetPresented: Bool = false
    @State private var deleteBudgetsError: DomainError?

    var body: some View {
        NavigationView {
            BudgetList(
                destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
                budgets: reportController.report.budgets,
                error: deleteBudgetsError,
                onAdd: { isAddNewBudgetPresented = true },
                onDelete: deleteBudgets(at:)
            )
            .sheet(isPresented: $isAddNewBudgetPresented) {
                NewBudgetView { budget in
                    try await reportController.add(budget: budget)
                    isAddNewBudgetPresented = false
                }
            }
            .toolbar { EditButton() }
            .navigationTitle(reportController.report.name)
            .onAppear {
                Task {
                    try? await reportController.fetch()
                }
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
        self.reportController = ReportController(report: Report.default(with: []), storageProvider: storageProvider)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(storageProvider: MockStorageProvider())
    }
}
