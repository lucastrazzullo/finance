//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    private enum TransactionType: String, CaseIterable {
        case expense = "Expense"
        case income = "Income"
    }

    @State private var isInsertNewTransactionPresented: Bool = false

    @State private var transactions: [Transaction] = []
    @State private var newTransactionAmount: String = ""
    @State private var newTransactionTypeIndex: Int = 0
    @State private var newTransactionSubcategoryIndex: Int = 0

    private var subcategories: [Subcategory] {
        Mocks.subcategories.filter { $0.category == category.id }
    }

    private var types: [TransactionType] {
        TransactionType.allCases
    }

    let category: Category

    var body: some View {
        VStack {
            Text(category.name)
                .font(.largeTitle)

            List {
                ForEach(transactions) { transaction in
                    let label = transaction.content.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.content.date)
                    AmountListItem(label: label, amount: transaction.amount)
                }

                Button("Add transactions") {
                    isInsertNewTransactionPresented = true
                }
            }
            .listStyle(PlainListStyle())

            ConfirmButton {
                if !transactions.isEmpty {
                    
                }
            }
            .disabled(transactions.isEmpty)
            .padding()
        }
        .sheet(isPresented: $isInsertNewTransactionPresented, onDismiss: {}) {
            Form {
                Section(header: Text("Type")) {
                    Picker("Type", selection: $newTransactionTypeIndex) {
                        ForEach(types.enumerated().map(\.offset), id: \.self) { index in
                            Text(types[index].rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Subcategory")) {
                    Picker("Subcategory", selection: $newTransactionSubcategoryIndex) {
                        ForEach(subcategories.enumerated().map(\.offset), id: \.self) { index in
                            Text(subcategories[index].name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section {
                    InsertAmountField(amountValue: $newTransactionAmount, title: "Amount", prompt: Text("New amount (e.g 10.22)"))
                }

                Section {
                    Button("Add") {
                        guard let amount = MoneyValue.string(newTransactionAmount) else {
                            return
                        }

                        let type = types[newTransactionTypeIndex]
                        let subcategory = subcategories[newTransactionSubcategoryIndex].id
                        let transactionContent = TransactionContent(amount: amount, category: category.id, subcategory: subcategory)

                        switch type {
                        case .expense:
                            transactions.append(.expense(transactionContent))
                        case .income:
                            transactions.append(.income(transactionContent))
                        }

                        newTransactionAmount = ""
                        newTransactionTypeIndex = 0
                        newTransactionSubcategoryIndex = 0

                        isInsertNewTransactionPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct InsertTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let subcategory = Mocks.subcategories.first!
        let category = Mocks.categories.first(where: { $0.id == subcategory.category })!
        return InsertTransactionsView(category: category)
    }
}
