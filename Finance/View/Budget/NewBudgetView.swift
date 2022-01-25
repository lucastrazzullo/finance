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

    @State private var newBudgetName: String = ""
    @State private var newBudgetAmount: String = ""
    @State private var newBudgetSlices: [BudgetSlice] = []
    @State private var newBudgetInlineError: InlineError?

    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New Budget")) {

                VStack(alignment: .leading) {
                    TextField("Name", text: $newBudgetName)

                    if let inlineError = newBudgetInlineError?.budgetError, case .nameNotValid = inlineError {
                        Text("Please insert a valid name")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }

                if newBudgetSlices.isEmpty {
                    VStack(alignment: .leading) {
                        InsertAmountField(amountValue: $newBudgetAmount, title: "Monthly Amount", prompt: nil)

                        if let inlineError = newBudgetInlineError?.budgetError, case .amountNotValid = inlineError  {
                            Text("Please insert a valid amount or add at least one slice")
                                .font(.caption2)
                                .foregroundColor(.teal)
                        }
                    }
                } else {
                    AmountCollectionItem(title: "Monthly total",
                                         caption: nil,
                                         amount: newBudgetSlices.totalAmount,
                                         color: .green)
                }
            }

            Section(header: Text("Slices")) {
                if !newBudgetSlices.isEmpty {
                    List {
                        ForEach(newBudgetSlices) { slice in
                            AmountListItem(label: slice.name, amount: slice.amount)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        newBudgetSlices.removeAll(where: { $0.id == slice.id })
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }

                    if let inlineError = newBudgetInlineError?.budgetError, case .sliceAlreadyExistsWith = inlineError {
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
                if let inlineError = newBudgetInlineError, case .unknown = inlineError {
                    Text("Something is wrong in the data you added")
                        .font(.caption2)
                        .foregroundColor(.teal)
                }

                Button("Save") {
                    do {
                        newBudgetInlineError = nil

                        if !newBudgetSlices.isEmpty {
                            onSubmit(try Budget(id: .init(), name: newBudgetName, slices: newBudgetSlices))
                        } else {
                            onSubmit(try Budget(id: .init(), name: newBudgetName, amount: newBudgetAmount))
                        }
                    } catch {
                        newBudgetInlineError = .init(error: error)
                    }
                }
            }
        }
        .sheet(isPresented: $isInsertNewBudgetSlicePresented, onDismiss: {}, content: {
            NewBudgetSliceView { slice in
                newBudgetSlices.append(slice)
                isInsertNewBudgetSlicePresented = false
            }
        })
    }
}

// MARK: - Previews

struct NewBudgetView_Previews: PreviewProvider {

    static var previews: some View {
        NewBudgetView() { _ in }
    }
}
