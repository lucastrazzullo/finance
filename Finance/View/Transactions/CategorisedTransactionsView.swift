//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import SwiftUI

struct CategorisedTransactionsView: View {

    @State private var isInsertTransactionsPresented: Bool = false

    let incoming: [Transaction] = Mocks.incomingTransactions
    let outgoing: [Transaction] = Mocks.outgoingTransactions

    var incomingCategories: [Category] {
        let categories = incoming.map(\.content.category)
        return Mocks.categories.filter { categories.contains($0.id) }
    }

    var outgoingCategories: [Category] {
        let categories = outgoing.map(\.content.category)
        return Mocks.categories.filter { categories.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Incoming transactions")) {
                    ForEach(incomingCategories) { category in
                        let transactions = incoming.filter { $0.content.category == category.id }
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: category)) {
                            AmountListItem(label: category.name, amount: transactions.totalAmount)
                        }
                    }
                }

                Section(header: Text("Outgoing transactions")) {
                    ForEach(outgoingCategories) { category in
                        let transactions = outgoing.filter { $0.content.category == category.id }
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: category)) {
                            AmountListItem(label: category.name, amount: transactions.totalAmount)
                        }
                    }
                }
            }
        }
    }

    // MARK: Private factory methods

    private func makeTransactionsView(with transactions: [Transaction], for category: Category) -> some View {
        TransactionsView(transactions: transactions)
            .navigationTitle(Text(category.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add transaction") {
                        isInsertTransactionsPresented = true
                    }
                }
            }
            .sheet(isPresented: $isInsertTransactionsPresented, onDismiss: nil) {
                InsertTransactionsView(category: category)
            }
    }
}

// MARK: - Previews

struct CategorisedTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategorisedTransactionsView()
        }
    }
}
