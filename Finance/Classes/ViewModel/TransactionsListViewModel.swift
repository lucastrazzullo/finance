//
//  TransactionsListViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import Foundation

protocol TransactionsListViewModel: ObservableObject {
    var transactions: [Transaction] { get }

    func add(transactions: [Transaction]) async throws
    func delete(transactionsAt offsets: IndexSet) async throws
}
