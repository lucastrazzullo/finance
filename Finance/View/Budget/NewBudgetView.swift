//
//  NewBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetView: View {

    typealias OnSubmitErrorHandler = (DomainError?) -> Void

    let onSubmit: (Budget, @escaping OnSubmitErrorHandler) -> Void

    @State private var budgetName: String = ""
    @State private var budgetAmount: String = ""
    @State private var budgetSlices: [BudgetSlice] = []

    @State private var presentedError: DomainError?
    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New budget")) {

                VStack(alignment: .leading) {
                    TextField("Name", text: $budgetName)

                    if let error = presentedError, case .budget(let inlineError) = error, case .nameNotValid = inlineError {
                        Color.red.frame(height: 2)
                    }
                }

                if budgetSlices.isEmpty {
                    VStack(alignment: .leading) {
                        InsertAmountField(amountValue: $budgetAmount, title: "Monthly Amount", prompt: nil)

                        if let error = presentedError, case .budget(let inlineError) = error, case .amountNotValid = inlineError  {
                            Color.red.frame(height: 2)
                        }
                    }
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
                                        budgetSlices.removeAll(where: { $0.id == slice.id })
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }

                    if let error = presentedError, case .budget(let inlineError) = error, case .slicesNotValid = inlineError {
                        Color.red.frame(height: 2)
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
                            onSubmit(try Budget(id: .init(), name: budgetName, slices: budgetSlices)) { error in
                                presentedError = error
                            }
                        } else {
                            onSubmit(try Budget(id: .init(), name: budgetName, amount: budgetAmount)) { error in
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
            NewBudgetSliceView { slice, onErrorHandler in
                do {
                    try Budget.canAdd(newSlice: slice, to: budgetSlices)
                    budgetSlices.append(slice)
                    isInsertNewBudgetSlicePresented = false
                } catch {
                    onErrorHandler(error as? DomainError ?? .underlying(error: error))
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
