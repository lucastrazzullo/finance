//
//  TransactionsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import SwiftUI

struct TransactionsListView: View {

    @ObservedObject var viewModel: TransactionsListViewModel

    var body: some View {
        List {
            ForEach(viewModel.months(), id: \.self) { month in
                Section(Calendar.current.standaloneMonthSymbols[month - 1]) {
                    ForEach(viewModel.transactions(month: month)) { transaction in
                        TransactionItem(transaction: transaction)
                            .accessibilityIdentifier(AccessibilityIdentifier.TransactionsListView.transactionLink)
                    }
                    .onDelete(perform: { indices in
                        Task { await viewModel.delete(transactionsAt: indices) }
                    })
                }
            }

            Button(action: viewModel.addTransactions) {
                Label("Add", systemImage: "plus")
                    .accessibilityIdentifier(AccessibilityIdentifier.TransactionsListView.addTransactionButton)
            }

            if let error = viewModel.deleteTransactionError {
                InlineErrorView(error: error)
            }
        }
        .listStyle(.plain)
    }
}

private struct TransactionItem: View {

    let transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.date, style: .date)
            Spacer()
            AmountView(amount: transaction.amount)
        }
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionsListView(
                viewModel: .init(
                    transactions: Mocks.transactions,
                    addTransactions: {},
                    deleteTransactions: { _ in }
                )
            )
            .navigationTitle("Transactions")
        }
    }
}
