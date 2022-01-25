//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @State private var isAddNewBudgetSlicePresented: Bool = false
    @State private var addNewBudgetSliceError: DomainError?

    @ObservedObject private var controller: BudgetController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmountCollectionItem(
                title: "Monthly",
                caption: "\(controller.yearlyAmount.value) per year",
                amount: controller.monthlyAmount,
                color: .gray.opacity(0.3)
            )
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    controller.delete(slice: slice) { result in
                                        if case let .failure(error) = result {
                                            addNewBudgetSliceError = error
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        Text("No slices defined for this budget")
                    }

                    Button(action: { isAddNewBudgetSlicePresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Label("Rename", systemImage: "square.and.pencil")
            }
        }
        .sheet(isPresented: $isAddNewBudgetSlicePresented) {
            NewBudgetSliceView { slice in
                controller.add(slice: slice) { result in
                    switch result {
                    case .success:
                        isAddNewBudgetSlicePresented = false
                    case .failure(let error):
                        addNewBudgetSliceError = error
                    }
                }
            }
            .sheet(item: $addNewBudgetSliceError) { error in
                ErrorView(error: error, options: [.retry], onSubmit: { option in
                    addNewBudgetSliceError = nil
                })
            }
        }
        .navigationTitle(controller.budget.name)
    }

    // MARK: - Private factory methods

    private func makePercentageStringFor(amount: MoneyValue) -> String {
        let percentage = NSDecimalNumber(decimal: amount.value * 100 / controller.budget.amount.value).floatValue
        return "\(percentage)%"
    }

    // MARK: - Object life cycle

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.controller = BudgetController(budget: budget, budgetProvider: budgetProvider)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let budgetProvider = MockBudgetProvider()
        NavigationView {
            BudgetView(budget: Mocks.budgets.last!, budgetProvider: budgetProvider)
        }
        .preferredColorScheme(.dark)
    }
}
