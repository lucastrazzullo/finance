//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    private enum TransactionType: String {
        case expense = "EXPENSE"
        case income = "INCOME"
    }

    @State private var transactions: [Transaction] = []
    @State private var newAmount: String = ""
    @State private var newTransactionType: String = TransactionType.expense.rawValue

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
                    let label = transaction.content.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.content.date)
                    AmountListItem(label: label, amount: transaction.amount)
                }

                HStack {
                    AmountField(amountValue: $newAmount,
                                title: "Amount",
                                prompt: Text("New amount (e.g 10.22)"))

                    Button("Add") {
//                        if let moneyValue = MoneyValue.string(newAmount) {
//                            let transaction = Transaction(amount: moneyValue,
//                                                          category: .init(),
//                                                          subcategory: .init())
//
//                            transactions.append(transaction)
//                        }
//                        newAmount = ""
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
