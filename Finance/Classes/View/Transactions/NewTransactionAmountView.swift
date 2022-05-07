//
//  NewTransactionAmountView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/05/2022.
//

import SwiftUI

struct NewTransactionAmountView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var budgetIndex: Int = 0
    @State private var budgetSliceIndex: Int = 0
    @State private var transactionAmount: Decimal? = nil
    @State private var submitError: DomainError?

    let budgets: [Budget]
    let onSubmit: (Transaction.Amount) -> Void

    var body: some View {
        Form {
            Section(header: Text("Budget")) {
                Picker("Select Budget", selection: $budgetIndex) {
                    ForEach(0..<budgets.count, id:\.self) { budgetIndex in
                        let budget = budgets[budgetIndex]
                        Text(budget.name)
                    }
                }

                Picker("Select Slice", selection: $budgetSliceIndex) {
                    ForEach(0..<budgets[budgetIndex].slices.count, id:\.self) { sliceIndex in
                        let slice = budgets[budgetIndex].slices[sliceIndex]
                        Text(slice.name)
                    }
                }
            }

            Section(header: Text("Amount")) {
                AmountTextField(amountValue: $transactionAmount, title: "Amount")
            }

            Section {
                if let error = submitError {
                    InlineErrorView(error: error)
                }

                Button("Save", action: submit)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Private helper methods

    private func submit() {
        do {
            guard let transactionAmount = transactionAmount else {
                throw DomainError.transaction(error: .amountNotValid)
            }

            let transactionBudget = budgets[budgetIndex]
            let transactionSlice = transactionBudget.slices[budgetSliceIndex]

            let amount = Transaction.Amount(
                amount: .value(transactionAmount),
                budgetIdentifier: transactionBudget.id,
                sliceIdentifier: transactionSlice.id
            )

            onSubmit(amount)
            submitError = nil
            presentationMode.wrappedValue.dismiss()
        } catch {
            submitError = error as? DomainError
        }
    }
}

struct NewTransactionAmountView_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionAmountView(budgets: Mocks.budgets) { _ in }
    }
}
