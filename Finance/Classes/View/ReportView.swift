//
//  ReportView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct ReportView: View {

    @ObservedObject private var controller: ReportController

    @State private var isAddNewBudgetPresented: Bool = false
    @State private var deleteBudgetsError: DomainError?

    private let storageProvider: StorageProvider

    var body: some View {
        BudgetList(
            storageProvider: storageProvider,
            budgets: controller.report.budgets,
            error: deleteBudgetsError,
            onAdd: { isAddNewBudgetPresented = true },
            onDelete: deleteBudgets(at:)
        )
        .sheet(isPresented: $isAddNewBudgetPresented) {
            NewBudgetView { budget in
                try await controller.add(budget: budget)
                isAddNewBudgetPresented = false
            }
        }
        .toolbar { EditButton() }
        .navigationTitle(controller.report.name)
        .onAppear {
            Task {
                try? await controller.fetch()
            }
        }
    }

    // MARK: Object life cycle

    init(report: Report, storageProvider: StorageProvider) {
        self.controller = ReportController(report: report, storageProvider: storageProvider)
        self.storageProvider = storageProvider
    }

    // MARK: Private helper methods

    private func deleteBudgets(at indices: IndexSet) {
        Task {
            do {
                try await controller.delete(budgetsAt: indices)
                deleteBudgetsError = nil
            } catch {
                deleteBudgetsError = error as? DomainError
            }
        }
    }
}

private struct BudgetList: View {

    let storageProvider: StorageProvider
    let budgets: [Budget]
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            Section(header: Text("Budgets")) {
                ForEach(budgets) { budget in
                    NavigationLink(destination: BudgetView(budget: budget, storageProvider: storageProvider)) {
                        AmountListItem(label: budget.name, amount: budget.amount)
                    }
                    .accessibilityIdentifier(AccessibilityIdentifier.ReportView.budgetLink)
                }
                .onDelete(perform: onDelete)

                if let error = error {
                    InlineErrorView(error: error)
                }

                Button(action: onAdd) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.ReportView.addBudgetButton)
                }
            }
        }
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        NavigationView {
            ReportView(report: Report.default(with: Mocks.budgets), storageProvider: storageProvider)
        }
    }
}
