//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/01/2022.
//

import SwiftUI

struct TransactionsView: View {

    let transactions: [Transaction]

    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionListItem(transaction: transaction)
            }
        }
    }
}

// MARK: - Previews

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        var transactions = [Transaction]()
        transactions.append(contentsOf: Mocks.outgoingTransactions)
        transactions.append(contentsOf: Mocks.incomingTransactions)

        return TransactionsView(transactions: transactions)
    }
}
