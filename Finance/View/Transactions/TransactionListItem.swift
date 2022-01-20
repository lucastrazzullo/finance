//
//  TransactionListItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 17/01/2022.
//

import SwiftUI

struct TransactionListItem: View {

    let transaction: Transaction

    var body: some View {
        let label = transaction.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.date)
        HStack {
            Text(label).font(.caption)
            Spacer()

            HStack {
                Image(systemName: makeIconName(for: transaction))
                AmountView(amount: transaction.amount)
            }
            .font(.subheadline)
            .padding(4)
            .background(makeBackgroundColor(for: transaction))
            .cornerRadius(4)
        }
    }

    // MARK: Private factory methods

    private func makeIconName(for transaction: Transaction) -> String {
        switch transaction.type {
        case .expense:
            return "minus"
        case .income:
            return "plus"
        }
    }

    private func makeBackgroundColor(for transaction: Transaction) -> Color {
        switch transaction.type {
        case .expense:
            return .yellow
        case .income:
            return .green
        }
    }
}

// MARK: - Previews

struct TransactionListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TransactionListItem(transaction: Mocks.outgoingTransactions.first!)
            TransactionListItem(transaction: Mocks.incomingTransactions.first!)
        }
    }
}
