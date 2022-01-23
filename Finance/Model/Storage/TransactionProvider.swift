//
//  TransactionProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

protocol TransactionProvider {
    typealias MutateCompletion = ((Result<Void, Swift.Error>) -> Void)
    typealias FetchCompletion = (Result<[Transaction], Swift.Error>) -> Void
    func add(transaction: Transaction, completion: @escaping MutateCompletion)
    func fetchTransactions(forBudgetWith budgetId: Budget.ID, completion: @escaping FetchCompletion)
}
