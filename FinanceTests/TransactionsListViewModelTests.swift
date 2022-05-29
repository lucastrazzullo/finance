//
//  TransactionsListViewModelTests.swift
//  FinanceTests
//
//  Created by Luca Strazzullo on 27/04/2022.
//

import XCTest

@testable import Finance

@MainActor final class TransactionsListViewModelTests: XCTestCase {

    private var viewModel: TransactionsListViewModel!

    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
    }

    @MainActor override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Transactions

    func testDeleteTransactions() async throws {
        let transactions = Mocks.transactions.filter({ $0.date.month == 1 })

        viewModel = TransactionsListViewModel(transactions: transactions, addTransactions: {}, deleteTransactions: { _ in })

        // Assert initial state
        XCTAssertNil(viewModel.deleteTransactionError)
        transactions.forEach { transaction in
            XCTAssertTrue(viewModel.transactions.contains(transaction))
        }

        // Delete transactions
        let offsets = IndexSet(integersIn: 0..<transactions.count)
        await viewModel.delete(transactionsAt: offsets)

        XCTAssertNil(viewModel.deleteTransactionError)
        transactions.forEach { transaction in
            XCTAssertFalse(viewModel.transactions.contains(transaction))
        }
    }
}
