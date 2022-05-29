//
//  TransactionsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import Foundation

@MainActor final class TransactionsListViewModel: ObservableObject {

    typealias AddTransactionsHandler = () -> Void
    typealias DeleteTransactionsHandler = (Set<Transaction.ID>) async throws -> Void

    @Published var transactions: [Transaction]
    @Published var deleteTransactionError: DomainError?

    let addTransactions: AddTransactionsHandler
    let deleteTransactions: DeleteTransactionsHandler

    // MARK: Object life cycle

    init(transactions: [Transaction], addTransactions: @escaping AddTransactionsHandler, deleteTransactions: @escaping DeleteTransactionsHandler) {
        self.transactions = transactions
        self.addTransactions = addTransactions
        self.deleteTransactions = deleteTransactions
    }

    // MARK: Internal methods

    func months() -> [Int] {
        return transactions.map(\.date.month).removeDuplicates()
    }

    func transactions(month: Int) -> [Transaction] {
        return transactions.filter({ $0.date.month == month })
    }

    func delete(transactionsAt offsets: IndexSet) async {
        let identifiers = transactions.at(offsets: offsets).map(\.id)
        let identifiersSet = Set(identifiers)

        do {
            try await deleteTransactions(identifiersSet)
            transactions.delete(withIdentifiers: identifiersSet)
            deleteTransactionError = nil
        } catch {
            deleteTransactionError = error as? DomainError
        }
    }
}
