//
//  NewBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetView: View {

    private enum InlineError {
        case budgetError(BudgetError)
        case unknown

        var budgetError: BudgetError? {
            if case .budgetError(let error) = self {
                return error
            } else {
                return nil
            }
        }

        init(error: Error) {
            if let domainError = error as? DomainError, case .budget(let budgetError) = domainError {
                self = .budgetError(budgetError)
            } else {
                self = .unknown
            }
        }
    }

    let onSubmit: (Budget) -> ()

    @State private var budgetName: String = ""
    @State private var budgetAmount: String = ""
    @State private var budgetSlices: [BudgetSlice] = []
    @State private var budgetInlineError: InlineError?

    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New budget")) {

                VStack(alignment: .leading) {
                    TextField("Name", text: $budgetName)

                    if let inlineError = budgetInlineError?.budgetError, case .nameNotValid = inlineError {
                        Text("Please insert a valid name")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }

                if budgetSlices.isEmpty {
                    VStack(alignment: .leading) {
                        InsertAmountField(amountValue: $budgetAmount, title: "Monthly Amount", prompt: nil)

                        if let inlineError = budgetInlineError?.budgetError, case .amountNotValid = inlineError  {
                            Text("Please insert a valid amount or add at least one slice")
                                .font(.caption2)
                                .foregroundColor(.teal)
                        }
                    }
                } else {
                    AmountCollectionItem(title: "Monthly total",
                                         caption: nil,
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

                    if let inlineError = budgetInlineError?.budgetError, case .sliceAlreadyExistsWith = inlineError {
                        Text("There's more than one slice with the same name.")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }
                Button(action: { isInsertNewBudgetSlicePresented = true }) {
                    Label("Add", systemImage: "plus")
                }
            }

            Section {
                if let inlineError = budgetInlineError, case .unknown = inlineError {
                    Text("Something is wrong in the data you added")
                        .font(.caption2)
                        .foregroundColor(.teal)
                }

                Button("Save") {
                    do {
                        budgetInlineError = nil

                        if !budgetSlices.isEmpty {
                            onSubmit(try Budget(id: .init(), name: budgetName, slices: budgetSlices))
                        } else {
                            onSubmit(try Budget(id: .init(), name: budgetName, amount: budgetAmount))
                        }
                    } catch {
                        budgetInlineError = .init(error: error)
                    }
                }
            }
        }
        .sheet(isPresented: $isInsertNewBudgetSlicePresented, onDismiss: {}, content: {
            NewBudgetSliceView { slice in
                budgetSlices.append(slice)
                isInsertNewBudgetSlicePresented = false
            }
        })
    }
}

// MARK: - Previews

struct NewBudgetView_Previews: PreviewProvider {

    static var previews: some View {
        NewBudgetView { _ in }
    }
}
