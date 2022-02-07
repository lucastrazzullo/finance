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
                    title: "Monthly",
                    caption: "\(controller.budget.yearlyAmount.localizedDescription) per year",
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
                            HStack {
                                AmountListItem(label: slice.name, amount: slice.amount)
                                Text(makePercentageStringFor(amount: slice.amount)).font(.caption)
                            }
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

    // MARK: - Private factory methods

    private func makePercentageStringFor(amount: MoneyValue) -> String {
        let percentage = NSDecimalNumber(decimal: amount.value * 100 / controller.budget.amount.value).floatValue
        return "\(percentage)%"
    }

    // MARK: - Object life cycle

    init(budget: Budget, budgetProvider: ReportProvider) {
        self.controller = BudgetController(budget: budget, budgetProvider: budgetProvider)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let storageProvider = MockBudgetStorageProvider()
        let budgetProvider = ReportProvider(storageProvider: storageProvider)
        NavigationView {
            BudgetView(budget: Mocks.budgets[0], budgetProvider: budgetProvider)
        }
    }
}
