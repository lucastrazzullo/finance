//
//  NewTransactionView.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/04/2022.
//

import SwiftUI

struct NewTransactionView: View {

    @State private var transactionDescription: String = ""
    @State private var transactionDate: Date = .now
    @State private var transactionAmount: Decimal? = nil
    @State private var budgetSliceId: BudgetSlice.ID?

    @State private var submitError: DomainError?

    let onSubmit: (Transaction) async throws -> Void

    var body: some View {
        VStack {
            Text("New transaction")
                .font(.title3.bold())
                .padding(.top)

            Form {
                Section(header: Text("Info")) {
                    TextField("Description", text: $transactionDescription)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewTransactionView.descriptionInputField)

                    DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)

                    AmountTextField(amountValue: $transactionAmount, title: "Amount")
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Save", action: submit)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.saveButton)
                }
            }
        }
    }

    // MARK: Private helper methods

    private func submit() {
        Task {
            do {
                guard let budgetSliceId = budgetSliceId else {
                    throw DomainError.transaction(error: .budgetSliceIsMissing)
                }
                guard let transactionAmount = transactionAmount else {
                    throw DomainError.transaction(error: .amountNotValid)
                }

                let transactionDescription = transactionDescription.isEmpty ? nil : transactionDescription

                let transaction = Transaction(
                    description: transactionDescription,
                    amount: MoneyValue.value(transactionAmount),
                    date: transactionDate,
                    budgetSliceId: budgetSliceId
                )

                try await onSubmit(transaction)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }
}

struct NewTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionView() { _ in }
    }
}
