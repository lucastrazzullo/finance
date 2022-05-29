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
    @State private var transactionAmounts: [Transaction.Amount] = []
    @State private var submitError: DomainError?

    let budgets: [Budget]
    let onSubmit: (Transaction) async throws -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: SectionHeader(title: "Info")) {
                    TextField("Description", text: $transactionDescription)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewTransactionView.descriptionInputField)

                    DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section(header: SectionHeader(title: "Amount", amount: transactionAmounts.balance)) {
                    ForEach(transactionAmounts, id: \.self) { amount in
                        AmountItem(amount: amount, budgets: budgets)
                    }
                    .onDelete { offsets in
                        transactionAmounts.remove(atOffsets: offsets)
                    }

                    NavigationLink(destination: NewTransactionAmountView(budgets: budgets, onSubmit: { amount in
                        transactionAmounts.append(amount)

                    })) {
                        Text("Add")
                    }
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Save", action: submit)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.saveButton)
                }
            }
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: Private helper methods

    private func submit() {
        Task {
            do {
                guard !transactionAmounts.isEmpty else {
                    throw DomainError.transaction(error: .amountNotValid)
                }

                let transactionDescription = transactionDescription.isEmpty ? nil : transactionDescription

                let transaction = try Transaction(
                    id: .init(),
                    description: transactionDescription,
                    date: transactionDate,
                    amounts: transactionAmounts
                )

                try await onSubmit(transaction)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }
}

private struct AmountItem: View {

    let amount: Transaction.Amount
    let budgets: [Budget]

    var body: some View {
        let budget = budgets.with(identifier: amount.budgetIdentifier)
        let slice = budget?.slices.with(identifier: amount.sliceIdentifier)

        HStack {
            if let budget = budget, let slice = slice {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: budget.icon.rawValue)
                        .symbolRenderingMode(.hierarchical)
                        .font(.body.bold())

                    VStack(alignment: .leading) {
                        Text(budget.name).font(.body.bold())
                        Text(slice.name).font(.caption)
                    }
                }
                .accentColor(.secondary)
            }

            Spacer()
            AmountView(amount: amount.amount)
        }
        .padding(.vertical, 8)
    }
}

private struct SectionHeader: View {

    let title: String
    let amount: MoneyValue?

    var body: some View {
        HStack {
            Text(title)

            if let amount = amount {
                Spacer()
                AmountView(amount: amount)
            }
        }
    }

    init(title: String, amount: MoneyValue? = nil) {
        self.title = title
        self.amount = amount
    }
}

struct NewTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NewTransactionView(budgets: Mocks.expenseBudgets) { _ in }
    }
}
