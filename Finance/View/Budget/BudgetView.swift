//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    final class Controller: ObservableObject {

        @Published var budget: Budget

        private weak var budgetProvider: BudgetProvider?

        var monthlyAmount: MoneyValue {
            budget.amount
        }

        var yearlyAmount: MoneyValue {
            budget.amount * .value(12)
        }

        init(budget: Budget, budgetProvider: BudgetProvider) {
            self.budget = budget
            self.budgetProvider = budgetProvider
        }

        func slicePercentage(amount: MoneyValue) -> Float {
            NSDecimalNumber(decimal: amount.value * 100 / budget.amount.value).floatValue
        }

        func add(slice: BudgetSlice) {
            do {
                try budget.add(slice: slice)
                budgetProvider?.add(budgetSlice: slice, toBudgetWith: budget.id) { [weak self] result in
                    if case .failure = result {
                        try? self?.budget.remove(slice: slice)
                    }
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    @State private var isAddSlicePresented: Bool = false
    @State private var newBudgetSliceName: String = ""
    @State private var newBudgetSliceAmount: String = ""

    @ObservedObject private var controller: Controller

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
                        }
                    } else {
                        Text("No slices defined for this budget")
                    }

                    Button(action: { isAddSlicePresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $isAddSlicePresented, onDismiss: {
            newBudgetSliceName = ""
            newBudgetSliceAmount = ""
        }, content: {
            Form {
                Section(header: Text("New Budget Slice")) {
                    TextField("Name", text: $newBudgetSliceName)
                    InsertAmountField(amountValue: $newBudgetSliceAmount, title: "Monthly Amount", prompt: nil)
                }

                Section {
                    Button("Save") {
                        guard let amount = MoneyValue.string(newBudgetSliceAmount) else {
                            return
                        }

                        controller.add(slice: BudgetSlice(id: .init(), name: newBudgetSliceName, amount: amount))
                        isAddSlicePresented = false
                    }
                }
            }
        })
        .navigationTitle(controller.budget.name)
    }

    // MARK: - Private helper methods

    private func makePercentageStringFor(amount: MoneyValue) -> String {
        return "\(controller.slicePercentage(amount: amount))%"
    }

    // MARK: - Object life cycle

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.controller = Controller(budget: budget, budgetProvider: budgetProvider)
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
