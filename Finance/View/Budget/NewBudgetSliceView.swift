//
//  NewBudgetSliceView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetSliceView: View {

    private enum InlineError {
        case budgetSliceError(BudgetSliceError)
        case unknown

        var budgetSliceError: BudgetSliceError? {
            if case .budgetSliceError(let error) = self {
                return error
            } else {
                return nil
            }
        }

        init(error: Error) {
            if let domainError = error as? DomainError, case .budgetSlice(let budgetSliceError) = domainError {
                self = .budgetSliceError(budgetSliceError)
            } else {
                self = .unknown
            }
        }
    }

    let onSubmit: (BudgetSlice) -> ()

    @State private var newBudgetSliceName: String = ""
    @State private var newBudgetSliceAmount: String = ""
    @State private var newBudgetSliceInlineError: InlineError?

    var body: some View {
        Form {
            Section(header: Text("New Budget Slice")) {

                VStack(alignment: .leading) {
                    TextField("Name", text: $newBudgetSliceName)

                    if let inlineError = newBudgetSliceInlineError?.budgetSliceError, case .nameNotValid = inlineError {
                        Text("Please insert a valid name")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }

                VStack(alignment: .leading) {
                    InsertAmountField(amountValue: $newBudgetSliceAmount, title: "Monthly Amount", prompt: nil)

                    if let inlineError = newBudgetSliceInlineError?.budgetSliceError, case .amountNotValid = inlineError {
                        Text("Please insert a valid amount")
                            .font(.caption2)
                            .foregroundColor(.teal)
                    }
                }
            }

            Section {
                Button("Save") {
                    do {
                        newBudgetSliceInlineError = nil
                        onSubmit(try BudgetSlice(id: .init(), name: newBudgetSliceName, amount: newBudgetSliceAmount))
                    } catch {
                        newBudgetSliceInlineError = .init(error: error)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct NewBudgetSliceView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceView() { _ in }
    }
}
