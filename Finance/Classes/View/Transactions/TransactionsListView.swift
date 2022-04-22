//
//  TransactionsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/04/2022.
//

import SwiftUI

struct TransactionsListView: View {

    let transactions: [Transaction]

    var body: some View {
        List {
            ForEach(transactions) { transaction in
                HStack {
                    Text(transaction.date, style: .date)
                    Spacer()
                    AmountView(amount: transaction.amount)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsListView(transactions: Mocks.transactions)
    }
}
