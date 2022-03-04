//
//  NewBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetView: View {

    typealias OnSubmitErrorHandler = (DomainError) -> Void

    let onSubmit: (Budget, @escaping OnSubmitErrorHandler) -> Void

    @State private var budgetName: String = ""
    @State private var budgetMonthlyAmount: String = ""
    @State private var budgetSlices: [BudgetSlice] = []

    @State private var presentedError: DomainError?
    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New budget")) {

                TextField("Name", text: $budgetName)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.nameInputField)

                if budgetSlices.isEmpty {
                    AmountTextField(amountValue: $budgetMonthlyAmount, title: "Monthly Amount", prompt: nil)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.amountInputField)
                } else {
                    AmountCollectionItem(title: "Total",
                                         caption: nil,
                                         amount: budgetSlices.totalAmount,
                                         color: .green)
                }
            }

            Section(header: Text("Slices")) {
                if !budgetSlices.isEmpty {
                    List {
                        ForEach(budgetSlices) { slice in
                            BudgetSlicesListItem(slice: slice, totalAmount: budgetSlices.totalAmount)
                                .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.sliceItem)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        budgetSlices.removeAll(where: { $0.id == slice.id })
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                Button(action: { isInsertNewBudgetSlicePresented = true }) {
                    Label("Add", systemImage: "plus")
                }
                .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.addSliceButton)
            }

            Section {
                if let error = presentedError {
                    InlineErrorView(error: error)
                }

                Button("Save", action: save)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.saveButton)
            }
        }
        .sheet(isPresented: $isInsertNewBudgetSlicePresented) {
            NewBudgetSliceView { newSlice, onErrorHandler in
                do {
                    try Budget.canAdd(slice: newSlice, to: budgetSlices)
                    budgetSlices.append(newSlice)
                    isInsertNewBudgetSlicePresented = false
                } catch {
                    onErrorHandler(error as? DomainError ?? .budget(error: .cannotAddSlice(underlyingError: error)))
                }
            }
        }
    }

    // MARK: Private helper methods

    private func save() {
        do {
            if !budgetSlices.isEmpty {
                let budget = try Budget(id: .init(), name: budgetName, slices: budgetSlices)
                onSubmit(budget) { error in
                    presentedError = error
                }
            } else {
                let budget = try Budget(id: .init(), name: budgetName, monthlyAmount: budgetMonthlyAmount)
                onSubmit(budget) { error in
                    presentedError = error
                }
            }
        } catch {
            presentedError = error as? DomainError ?? .budget(error: .cannotCreateTheBudget(underlyingError: error))
        }
    }
}

// MARK: - Previews

struct NewBudgetView_Previews: PreviewProvider {

    static var previews: some View {
        NewBudgetView { _, _ in }
    }
}
