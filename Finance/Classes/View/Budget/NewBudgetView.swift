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
    @State private var budgetAmount: String = ""
    @State private var budgetSlices: [BudgetSlice] = []

    @State private var presentedError: DomainError?
    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New budget")) {

                TextField("Name", text: $budgetName)

                if budgetSlices.isEmpty {
                    InsertAmountField(amountValue: $budgetAmount, title: "Monthly Amount", prompt: nil)
                } else {
                    AmountCollectionItem(title: "Monthly total",
                                         caption: "\(Budget.yearlyAmount(for: budgetSlices.totalAmount).localizedDescription) per year",
                                         amount: budgetSlices.totalAmount,
                                         color: .green)
                }
            }

            Section(header: Text("Slices")) {
                if !budgetSlices.isEmpty {
                    List {
                        ForEach(budgetSlices) { slice in
                            AmountListItem(label: slice.name, amount: slice.amount)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        do {
                                            try Budget.canRemove(slice: slice, from: budgetSlices)
                                            budgetSlices.removeAll(where: { $0.id == slice.id })
                                        } catch {
                                            presentedError = error as? DomainError ?? .budget(error: .cannotDeleteSlice(underlyingError: error))
                                        }
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
            }

            Section {
                if let error = presentedError {
                    InlineErrorView(error: error)
                }

                Button("Save") {
                    do {
                        if !budgetSlices.isEmpty {
                            let budget = try Budget(id: .init(), name: budgetName, slices: budgetSlices)
                            onSubmit(budget) { error in
                                presentedError = error
                            }
                        } else {
                            let budget = try Budget(id: .init(), name: budgetName, amount: budgetAmount)
                            onSubmit(budget) { error in
                                presentedError = error
                            }
                        }
                    } catch {
                        presentedError = error as? DomainError ?? .budget(error: .cannotCreateTheBudget(underlyingError: error))
                    }
                }
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
}

// MARK: - Previews

struct NewBudgetView_Previews: PreviewProvider {

    static var previews: some View {
        NewBudgetView { _, _ in }
    }
}
