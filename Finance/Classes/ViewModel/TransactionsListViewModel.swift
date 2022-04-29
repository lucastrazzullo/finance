//
//  TransactionsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import Foundation

protocol TransactionsListDataProvider: AnyObject {
    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws
}

final class TransactionsListViewModel: ObservableObject {

    @Published var deleteTransactionError: DomainError?

    let transactions: [Transaction]
    private let dataProvider: TransactionsListDataProvider

    // MARK: Object life cycle

    init(transactions: [Transaction], dataProvider: TransactionsListDataProvider) {
        self.transactions = transactions
        self.dataProvider = dataProvider
    }

    // MARK: Internal methods

    func delete(transactionsAt offsets: IndexSet) async {
        do {
            let identifiers = transactions.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await dataProvider.delete(transactionsWith: identifiersSet)
            deleteTransactionError = nil
        } catch {
            deleteTransactionError = error as? DomainError
        }
    }
}
