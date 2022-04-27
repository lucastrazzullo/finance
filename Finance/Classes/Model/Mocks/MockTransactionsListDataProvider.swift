//
//  MockTransactionsListDataProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import Foundation

final class MockTransactionsListDataProvider: TransactionsListDataProvider {

    var transactions: [Transaction] = Mocks.transactions

    init(transactions: [Transaction]) {
        self.transactions = transactions
    }

    func add(transactions: [Transaction]) async throws {
        self.transactions.append(contentsOf: transactions)
    }

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        self.transactions.removeAll(where: { identifiers.contains($0.id) })
    }
}
