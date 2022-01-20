//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    final class Controller: ObservableObject {

        let budget: Budget

        init(budget: Budget) {
            self.budget = budget
        }

        lazy var transactionTypes: [Transaction.TransactionType] = {
            Transaction.TransactionType.allCases
        }()

        lazy var budgetSlicesId: [BudgetSlice.ID] = {
            budget.slices.map(\.id)
        }()
    }

    @State private var isInsertNewTransactionPresented: Bool = false

    @State private var transactions: [Transaction] = []
    @State private var newTransactionAmount: String = ""
    @State private var newTransactionTypeIndex: Int = 0
    @State private var newTransactionBudgetSliceIndex: Int = 0

    @ObservedObject private var controller: Controller

    var body: some View {
        VStack {
            Text(controller.budget.name)
                .font(.largeTitle)

            List {
                ForEach(transactions) { transaction in
                    let label = transaction.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.date)
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
                Section(header: Text("Transaction Type")) {
                    Picker("Transaction Type", selection: $newTransactionTypeIndex) {
                        ForEach(controller.transactionTypes.enumerated().map(\.offset), id: \.self) { index in
                            Text(controller.transactionTypes[index].rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Subcategory")) {
                    Picker("Subcategory", selection: $newTransactionBudgetSliceIndex) {
                        ForEach(controller.budgetSlicesId.enumerated().map(\.offset), id: \.self) { index in
                            let sliceIdentifier = controller.budgetSlicesId[index]
                            if let slice = controller.budget.slices.first(where: { $0.id == sliceIdentifier }) {
                                AmountListItem(label: slice.name, amount: slice.amount)
                            }
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

                        let transactionType = controller.transactionTypes[newTransactionTypeIndex]
                        let budgetSliceId = controller.budgetSlicesId[newTransactionBudgetSliceIndex]
                        let transaction = Transaction(amount: amount, type: transactionType, budgetId: controller.budget.id, budgetSliceId: budgetSliceId)
                        transactions.append(transaction)

                        newTransactionAmount = ""
                        newTransactionTypeIndex = 0
                        newTransactionBudgetSliceIndex = 0

                        isInsertNewTransactionPresented = false
                    }
                }
            }
        }
    }

    init(budget: Budget) {
        self.controller = Controller(budget: budget)
    }
}

// MARK: - Previews

struct InsertTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let budget = Budget(name: "Test", slices: [
            .default(amount: .value(200)),
            .default(amount: .value(100)),
            .default(amount: .value(500))
        ])
        return InsertTransactionsView(budget: budget)
    }
}
