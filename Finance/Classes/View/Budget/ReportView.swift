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
    @State private var updateBudgetsError: DomainError?

    var body: some View {
        ZStack {
            if let report = controller.report {
                List {
                    Section(header: Text("Budgets")) {
                        ForEach(report.budgets) { budget in
                            NavigationLink(destination: BudgetView(budget: budget, storageProvider: controller.storageProvider)) {
                                AmountListItem(label: budget.name, amount: budget.amount)
                            }
                            .accessibilityIdentifier(AccessibilityIdentifier.ReportView.budgetLink)
                        }
                        .onDelete { offsets in
                            controller.delete(budgetsAt: offsets) { result in
                                if case let .failure(error) = result {
                                    updateBudgetsError = error
                                } else {
                                    updateBudgetsError = nil
                                }
                            }
                        }

                        if let error = updateBudgetsError {
                            InlineErrorView(error: error)
                        }

                        Button(action: { isAddNewBudgetPresented = true }) {
                            Label("Add", systemImage: "plus")
                                .accessibilityIdentifier(AccessibilityIdentifier.ReportView.addBudgetButton)
                        }
                    }
                }
                .sheet(isPresented: $isAddNewBudgetPresented) {
                    NewBudgetView() { createdBudget, errorHandler in
                        controller.add(budget: createdBudget) { result in
                            switch result {
                            case .success:
                                isAddNewBudgetPresented = false
                            case .failure(let error):
                                errorHandler(error)
                            }
                        }
                    }
                }
                .toolbar {
                    EditButton()
                }
                .navigationTitle(report.name)
            } else {
                InlineErrorView(error: .report(error: .reportIsNotLoaded))
            }
        }
        .onAppear(perform: controller.fetch)
    }

    init(storageProvider: StorageProvider) {
        self.controller = ReportController(storageProvider: storageProvider)
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        NavigationView {
            ReportView(storageProvider: storageProvider)
        }
    }
}
