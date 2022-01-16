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
                let label = transaction.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.date)
                AmountListItem(label: label, amount: transaction.amount)
            }
        }

    }
}

// MARK: - Previews

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView(transactions: Mocks.outgoingTransactions)
    }
}
