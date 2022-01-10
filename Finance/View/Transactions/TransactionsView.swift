//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import SwiftUI

struct TransactionsView: View {

    @State private var isNewEntrySheetPresented: Bool = false

    let incoming: [Transaction] = Mocks.incomingTransactions
    let outgoing: [Transaction] = Mocks.outgoingTransactions

    var incomingCategories: [Category] {
        let categories = incoming.map(\.category)
        return Mocks.categories.filter { categories.contains($0.id) }
    }

    var outgoingCategories: [Category] {
        let categories = outgoing.map(\.category)
        return Mocks.categories.filter { categories.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Incoming transactions")) {
                    ForEach(incomingCategories) { category in
                        let transactions = incoming.filter { $0.category == category.id }
                        AmountListItem(label: category.name, amount: transactions.totalAmount)
                    }
                }

                Section(header: Text("Outgoing transactions")) {
                    ForEach(outgoingCategories) { category in
                        let transactions = outgoing.filter { $0.category == category.id }
                        AmountListItem(label: category.name, amount: transactions.totalAmount)
                    }
                }
            }

            Button("Add transactions") { isNewEntrySheetPresented = true }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.thinMaterial)
        }
        .sheet(isPresented: $isNewEntrySheetPresented, content: {
            UpdateFinanceView()
        })
    }
}

// MARK: - Previews

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
