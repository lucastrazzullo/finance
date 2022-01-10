//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    @State private var transactions: [Transaction] = []
    @State private var newAmount: String = ""

    var body: some View {
        VStack {
            AmountCollectionItem(
                title: "Total",
                caption: nil,
                amount: transactions.totalAmount,
                color: .yellow
            )

            List {
                ForEach(transactions) { transaction in
                    let label = transaction.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.date)
                    AmountListItem(label: label, amount: transaction.amount)
                }

                HStack {
                    AmountField(amountValue: $newAmount,
                                title: "Amount",
                                prompt: Text("New amount (e.g 10.22)"))

                    Button("Add") {
                        if let moneyValue = MoneyValue.string(newAmount) {
                            let transaction = Transaction(amount: moneyValue,
                                                          category: .init(),
                                                          subcategory: .init())

                            transactions.append(transaction)
                        }
                        newAmount = ""
                    }
                }
            }
            .listStyle(PlainListStyle())

            ConfirmButton {
                if !transactions.isEmpty {
                    
                }
            }
            .disabled(transactions.isEmpty)
        }
    }
}

// MARK: - Previews

struct InsertTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        InsertTransactionsView()
            .padding(12)
    }
}
