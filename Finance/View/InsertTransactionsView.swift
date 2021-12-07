//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy hh:mm"
        return formatter
    }()

    @State private var transactions: [Transaction] = []
    @State private var newAmount: String = ""

    var onSubmit: ([Transaction]) -> ()

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
                    let date = formatter.string(from: transaction.date)
                    AmountListItem(label: date, amount: transaction.amount)
                }

                HStack {
                    AmountField(amountValue: $newAmount,
                                title: "Amount",
                                prompt: Text("New amount (e.g 10.22)"))

                    Button("Add") {
                        if let moneyValue = MoneyValue.string(newAmount) {
                            let transaction = Transaction(amount: moneyValue)
                            transactions.append(transaction)
                        }
                        newAmount = ""
                    }
                }
            }
            .listStyle(PlainListStyle())

            ConfirmButton {
                if !transactions.isEmpty {
                    onSubmit(transactions)
                }
            }
            .disabled(transactions.isEmpty)
        }
    }
}

// MARK: - Previews

struct InsertTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        InsertTransactionsView() { _ in }
            .padding(12)
    }
}
