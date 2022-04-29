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

    @Published var transactions: [Transaction]
    @Published var deleteTransactionError: DomainError?

    private let dataProvider: TransactionsListDataProvider

    // MARK: Object life cycle

    init(transactions: [Transaction], dataProvider: TransactionsListDataProvider) {
        self.transactions = transactions
        self.dataProvider = dataProvider
    }

    // MARK: Internal methods

    func months() -> [Int] {
        return transactions.map(\.month).removeDuplicates()
    }

    func transactions(month: Int) -> [Transaction] {
        return transactions.filter({ $0.month == month })
    }

    func delete(transactionsAt offsets: IndexSet) async {
        do {
            let identifiers = transactions.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await dataProvider.delete(transactionsWith: identifiersSet)
            transactions.delete(withIdentifiers: identifiersSet)
            deleteTransactionError = nil
        } catch {
            deleteTransactionError = error as? DomainError
        }
    }
}
