//
//  NewBudgetSliceView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetSliceView: View {

    typealias OnSubmitErrorHandler = (DomainError) -> Void

    let onSubmit: (BudgetSlice, OnSubmitErrorHandler) -> Void

    @State private var newBudgetSliceName: String = ""
    @State private var newBudgetSliceAmount: String = ""
    @State private var newBudgetSlicePresentedError: DomainError?

    var body: some View {
        Form {
            Section(header: Text("New Budget Slice")) {

                VStack(alignment: .leading) {
                    TextField("Name", text: $newBudgetSliceName)
                }

                VStack(alignment: .leading) {
                    InsertAmountField(amountValue: $newBudgetSliceAmount, title: "Monthly Amount", prompt: nil)
                }
            }

            Section {
                if let error = newBudgetSlicePresentedError {
                    InlineErrorView(error: error)
                }

                Button("Save") {
                    do {
                        let slice = try BudgetSlice(id: .init(), name: newBudgetSliceName, amount: newBudgetSliceAmount)
                        onSubmit(slice) { error in
                            newBudgetSlicePresentedError = error
                        }
                    } catch {
                        newBudgetSlicePresentedError = error as? DomainError ?? .budgetSlice(error: .cannotCreateTheSlice(underlyingError: error))
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct NewBudgetSliceView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceView { _, _ in }
    }
}
