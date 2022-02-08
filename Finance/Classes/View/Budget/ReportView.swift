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
        List {
            ForEach(controller.report.budgets) { budget in
                NavigationLink(destination: BudgetView(budget: budget, storageProvider: controller.storageProvider)) {
                    AmountListItem(label: budget.name, amount: budget.amount)
                }
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
        .navigationTitle(controller.report.name)
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
