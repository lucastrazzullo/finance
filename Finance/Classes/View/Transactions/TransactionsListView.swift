//
//  TransactionsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import SwiftUI

struct TransactionsListView<ViewModel: TransactionsListViewModel>: View {

    @ObservedObject var viewModel: ViewModel

    @State var deleteTransactionError: DomainError?

    var body: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                HStack {
                    Text(transaction.date, style: .date)
                    Spacer()
                    AmountView(amount: transaction.amount)
                }
            }
            .onDelete { offsets in Task {
                do {
                    try await viewModel.delete(transactionsAt: offsets)
                    deleteTransactionError = nil
                } catch {
                    deleteTransactionError = error as? DomainError
                }
            }}

            if let error = deleteTransactionError {
                InlineErrorView(error: error)
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionsListView(viewModel: MockViewModel())
                .navigationTitle("Transactions")
        }
    }
}

private final class MockViewModel: TransactionsListViewModel {

    var transactions: [Transaction] = Mocks.transactions

    func add(transactions: [Transaction]) async throws {
    }

    func delete(transactionsAt offsets: IndexSet) async {
    }
}
