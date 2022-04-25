//
//  TransactionsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import Foundation

protocol TransactionsListViewModelDelegate: AnyObject {
    func didDelete(transactionsWith identifiers: Set<Transaction.ID>)
}

@MainActor final class TransactionsListViewModel: ObservableObject {

    @Published var transactions: [Transaction]
    @Published var deleteTransactionError: DomainError?

    private let storageProvider: StorageProvider
    private weak var delegate: TransactionsListViewModelDelegate?

    init(transactions: [Transaction], storageProvider: StorageProvider, delegate: TransactionsListViewModelDelegate?) {
        self.transactions = transactions
        self.storageProvider = storageProvider
        self.delegate = delegate
    }

    func delete(transactionsAt offsets: IndexSet) async {
        do {
            let identifiers = transactions.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)

            try await storageProvider.delete(transactionsWith: identifiersSet)

            transactions.remove(atOffsets: offsets)
            delegate?.didDelete(transactionsWith: identifiersSet)
            
            deleteTransactionError = nil
        } catch {
            deleteTransactionError = error as? DomainError
        }
    }
}
