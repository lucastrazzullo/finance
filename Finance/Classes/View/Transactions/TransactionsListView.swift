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
            }
            .onDelete { offsets in Task { await viewModel.delete(transactionsAt: offsets) } }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionsListView(
                viewModel: .init(
                    transactions: Mocks.transactions,
                    storageProvider: MockStorageProvider(),
                    delegate: nil
                )
            )
            .navigationTitle("Transactions")
        }
    }
}
