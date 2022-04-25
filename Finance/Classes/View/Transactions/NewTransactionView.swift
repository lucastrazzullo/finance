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

    @State private var budgetIndex: Int = 0
    @State private var budgetSliceIndex: Int = 0

    @State private var submitError: DomainError?

    let budgets: [Budget]
    let onSubmit: (Transaction) async throws -> Void

    var body: some View {
        NavigationView {
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

                Section(header: Text("Info")) {
                    TextField("Description", text: $transactionDescription)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewTransactionView.descriptionInputField)

                    DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section(header: Text("Amount")) {
                    AmountTextField(amountValue: $transactionAmount, title: "Amount")
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Add", action: submit)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.saveButton)
                }
            }
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private helper methods

    private func submit() {
        Task {
            do {
                guard let transactionAmount = transactionAmount else {
                    throw DomainError.transaction(error: .amountNotValid)
                }

                let transactionDescription = transactionDescription.isEmpty ? nil : transactionDescription

                let transaction = Transaction(
                    id: .init(),
                    description: transactionDescription,
                    amount: MoneyValue.value(transactionAmount),
                    date: transactionDate,
                    budgetSliceId: budgets[budgetIndex].slices[budgetSliceIndex].id
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
        NewTransactionView(budgets: Mocks.budgets) { _ in }
    }
}
