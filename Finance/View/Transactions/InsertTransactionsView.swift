//
//  InsertTransactionsView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct InsertTransactionsView: View {

    final class Controller: ObservableObject {

        enum TransactionType: String, CaseIterable {
            case expense, income
        }

        let budget: Budget

        init(budget: Budget) {
            self.budget = budget
        }

        lazy var transactionTypes: [TransactionType] = {
            return TransactionType.allCases
        }()

        lazy var budgetSlicesId: [BudgetSlice.ID] = {
            budget.slices.map(\.id)
        }()
    }

    @State private var isInsertNewTransactionPresented: Bool

    @State private var transactions: [Transaction] = []
    @State private var newTransactionAmount: String = ""
    @State private var newTransactionTypeIndex: Int = 0
    @State private var newTransactionBudgetSliceIndex: Int

    @ObservedObject private var controller: Controller

    var body: some View {
        VStack {
            Text(controller.budget.name)
                .font(.largeTitle)
                .padding(.top)

            List {
                ForEach(transactions) { transaction in
                    let label = transaction.description ?? DateFormatter.transactionDateFormatter.string(from: transaction.date)
                    AmountListItem(label: label, amount: transaction.transfer.amount)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                transactions.removeAll(where: { $0.id == transaction.id })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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

                        let budgetSliceId = controller.budgetSlicesId[newTransactionBudgetSliceIndex]
                        let transactionType = controller.transactionTypes[newTransactionTypeIndex]
                        let transfer: Transfer = {
                            switch transactionType {
                            case .expense:
                                return .expense(amount: amount)
                            case .income:
                                return .income(amount: amount)
                            }
                        }()

                        let transaction = Transaction(transfer: transfer, budgetId: controller.budget.id, budgetSliceId: budgetSliceId)
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

    init(budget: Budget, initialSliceId: BudgetSlice.ID? = nil, initialInsertionPresented: Bool = false) {
        let controller = Controller(budget: budget)
        self.controller = controller
        self.isInsertNewTransactionPresented = initialInsertionPresented

        if let initialSliceId = initialSliceId,
           let initialIndex = controller.budgetSlicesId.firstIndex(of: initialSliceId) {
            self.newTransactionBudgetSliceIndex = initialIndex
        } else {
            self.newTransactionBudgetSliceIndex = 0
        }
    }
}

// MARK: - Previews

struct InsertTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let budget = Budget(id: UUID(), name: "Test", slices: [
            .init(name: "", amount: .value(200)),
            .init(name: "", amount: .value(100)),
            .init(name: "", amount: .value(500))
        ])
        return InsertTransactionsView(budget: budget)
    }
}
