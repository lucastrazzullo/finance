//
//  AddTransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 15/04/2022.
//

import SwiftUI

struct AddTransactionsView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var addNewTransactionPresented: Bool = false
    @State private var transactions: [Transaction] = []

    @State private var initError: DomainError?
    @State private var submitError: DomainError?

    let budgets: [Budget]
    let onSubmit: ([Transaction]) async throws -> Void

    var body: some View {
        NavigationView {
            ZStack {
                if let error = initError {
                    ErrorView(error: error, action: .init(label: "Ok") {
                        presentationMode.wrappedValue.dismiss()
                    })
                } else {
                    List {
                        Section {
                            ForEach(transactions, id: \.self) { transaction in
                                TransactionItem(transaction: transaction, budgets: budgets)
                            }
                            .onDelete { transactions.remove(atOffsets: $0) }
                        }

                        Section {
                            Button(action: { addNewTransactionPresented = true }) {
                                Label("Add", systemImage: "plus")
                            }
                            .listRowSeparator(.hidden)
                            .padding(.vertical)
                        }

                        Section(header: SectionHeader(label: "Total", amount: transactions.totalAmount)) {
                            if let error = submitError {
                                InlineErrorView(error: error)
                            }

                            Button(action: save) {
                                Text("Save")
                            }
                            .buttonStyle(.borderedProminent)
                            .listRowSeparator(.hidden)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Add transactions")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $addNewTransactionPresented) {
                NewTransactionView(budgets: budgets, onSubmit: add(transaction:))
            }
        }
    }

    // MARK: Private helper methods

    private func add(transaction: Transaction) async throws {
        transactions.append(transaction)
        addNewTransactionPresented = false
    }

    private func save() {
        Task {
            do {
                try await onSubmit(transactions)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }

    // MARK: Object life cycle

    init(budgets: [Budget], onSubmit: @escaping ([Transaction]) async throws -> Void) {
        self.budgets = budgets
        self.onSubmit = onSubmit

        self._initError = State(wrappedValue: budgets.isEmpty ? .transaction(error: .budgetsAreMissing) : nil)
    }
}

private struct SectionHeader: View {

    let label: String
    let amount: MoneyValue

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            AmountView(amount: amount)
        }
    }
}

private struct TransactionItem: View {

    let label: String
    let date: Date
    let amount: MoneyValue

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label).font(.headline)
                Text(date, style: .date).font(.caption)
            }

            Spacer()

            AmountView(amount: amount)
        }
        .padding(.vertical, 8)
    }

    init(transaction: Transaction, budgets: [Budget]) {
        self.label = transaction
            .amounts
            .compactMap { amount in
                budgets
                    .with(identifier: amount.budgetIdentifier)?
                    .slices
                    .with(identifier: amount.sliceIdentifier)?
                    .name
            }
            .joined(separator: ", ")

        self.date = transaction.date
        self.amount = transaction.amount
    }
}

struct AddTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionsView(budgets: Mocks.budgets) { _ in }
    }
}
