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
            ForEach(viewModel.transactions) { transaction in
                HStack {
                    Text(transaction.date, style: .date)
                    Spacer()
                    AmountView(amount: transaction.amount)
                }
                .accessibilityIdentifier(AccessibilityIdentifier.TransactionsListView.transactionLink)
            }
            .onDelete { offsets in
                Task {
                    await viewModel.delete(transactionsAt: offsets)
                }
            }

            if let error = viewModel.deleteTransactionError {
                InlineErrorView(error: error)
            }
        }
        .listStyle(.plain)
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionsListView(viewModel: .init(month: 1, dataProvider: MockTransactionsListDataProvider(transactions: Mocks.transactions)))
                .navigationTitle("Transactions")
        }
    }
}
