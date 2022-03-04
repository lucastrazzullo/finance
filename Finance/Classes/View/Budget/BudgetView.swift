//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @ObservedObject private var controller: BudgetController

    @State private var isUpdateBudgetPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                AmountCollectionItem(
                    title: "Total Amount",
                    caption: nil,
                    amount: controller.budget.amount,
                    color: .gray.opacity(0.3)
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            List {
                Section(header: Text("Slices")) {
                    if controller.budget.slices.count > 0 {
                        ForEach(controller.budget.slices) { slice in
                            BudgetSlicesListItem(slice: slice, totalAmount: controller.budget.amount)
                        }
                    } else {
                        Text("No slices defined for this budget")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $isUpdateBudgetPresented) {
            UpdateBudgetView(budget: controller.budget) { updatedBudget, errorHandler in
                controller.update(budget: updatedBudget) { result in
                    switch result {
                    case .success:
                        isUpdateBudgetPresented = false
                    case .failure(let error):
                        errorHandler(error)
                    }
                }
            }
        }
        .toolbar {
            Button(action: { isUpdateBudgetPresented = true }) {
                Text("Edit")
            }
        }
        .navigationTitle(controller.budget.name)
        .onAppear(perform: controller.fetch)
    }

    // MARK: - Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.controller = BudgetController(budget: budget, storageProvider: storageProvider)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let storageProvider = MockStorageProvider()
        NavigationView {
            BudgetView(budget: Mocks.budgets[0], storageProvider: storageProvider)
        }
    }
}
