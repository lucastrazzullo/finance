//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @Environment(\.editMode) var editMode

    @State private var isAddNewSlicePresented: Bool = false
    @State private var newBudgetName: String = ""

    @State private var inlineError: DomainError?
    @State private var presentedError: DomainError?

    @ObservedObject private var controller: BudgetController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                if isEditing() {
                    HStack {
                        TextField("Name", text: $newBudgetName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        if controller.budget.name != newBudgetName {
                            Button(action: {
                                do {
                                    inlineError = nil

                                    try Budget.canUse(name: newBudgetName)
                                    controller.update(name: newBudgetName) { result in
                                        switch result {
                                        case .success:
                                            break
                                        case .failure(let error):
                                            inlineError = error
                                        }
                                    }
                                } catch let error as DomainError {
                                    inlineError = error
                                } catch let error {
                                    assertionFailure(error.localizedDescription)
                                }
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }

                    if case .budget(let error) = inlineError, case .nameNotValid = error {
                        Text("Please insert a valid name")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }

                AmountCollectionItem(
                    title: "Monthly",
                    caption: "\(controller.yearlyAmount.localizedDescription) per year",
                    amount: controller.monthlyAmount,
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
                        .onDelete { offsets in
                            guard offsets.count == 1 else {
                                return
                            }
                            controller.delete(slice: controller.budget.slices[offsets.first!]) { result in
                                if case .failure(let error) = result {
                                    presentedError = error
                                }
                            }
                        }
                        .deleteDisabled(!isEditing())
                    } else {
                        Text("No slices defined for this budget")
                    }

                    if isEditing() {
                        Button(action: { isAddNewSlicePresented = true }) {
                            Label("Add slice", systemImage: "plus")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            EditButton()
        }
        .onChange(of: isEditing()) { isEditing in
            if isEditing {
                newBudgetName = controller.budget.name
            } else {
                newBudgetName = ""
            }
        }
        .sheet(isPresented: $isAddNewSlicePresented) {
            NewBudgetSliceView { slice in
                controller.add(slice: slice) { result in
                    switch result {
                    case .success:
                        isAddNewSlicePresented = false
                    case .failure(let error):
                        presentedError = error
                    }
                }
            }
            .sheet(item: $presentedError) { error in
                ErrorView(error: error, options: [.dismiss], onSubmit: { option in
                    presentedError = nil
                })
            }
        }
        .navigationTitle(isEditing() ? newBudgetName : controller.budget.name)
    }

    // MARK: - Private factory methods

    private func isEditing() -> Bool {
        return editMode?.wrappedValue.isEditing ?? false
    }

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
