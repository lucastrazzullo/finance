//
//  TransactionsListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class TransactionsListViewModelTests: XCTestCase {

    private var storageProvider: StorageProvider!
    private var viewModel: TransactionsListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        storageProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Transactions

    func testDeleteTransactions() async throws {
        let transactionToDelete = Mocks.transactions[0]
        storageProvider = MockStorageProvider(budgets: [], transactions: Mocks.transactions)
        viewModel = TransactionsListViewModel(transactions: Mocks.transactions, storageProvider: storageProvider, delegate: nil)

        XCTAssertNil(viewModel.deleteTransactionError)
        XCTAssertTrue(viewModel.transactions.contains(transactionToDelete))

        await viewModel.delete(transactionsAt: .init(integer: 0))

        XCTAssertNil(viewModel.deleteTransactionError)
        XCTAssertFalse(viewModel.transactions.contains(transactionToDelete))
    }
}
