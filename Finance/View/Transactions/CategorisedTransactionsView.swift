//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import SwiftUI

struct CategorisedTransactionsView: View {

    final class Controller: ObservableObject {
        private let incoming: [Transaction] = Mocks.incomingTransactions
        private let outgoing: [Transaction] = Mocks.outgoingTransactions

        lazy var incomingBudgets: [Budget] = {
            incoming
                .map(\.budgetId)
                .removeDuplicates()
                .compactMap({ budgetId in
                    BudgetProvider.incomingBudgetList.first(where: { $0.id == budgetId })
                })
        }()

        lazy var expensesBudgets: [Budget] = {
            outgoing
                .map(\.budgetId)
                .removeDuplicates()
                .compactMap({ budgetId in
                    BudgetProvider.expensesBudgetList.first(where: { $0.id == budgetId })
                })
        }()

        func incomingTransactions(for budgetId: Budget.ID) -> [Transaction] {
            incoming.filter { $0.budgetId == budgetId }
        }

        func outgoingTransactions(for budgetId: Budget.ID) -> [Transaction] {
            outgoing.filter { $0.budgetId == budgetId }
        }
    }

    @State private var isInsertTransactionsPresented: Bool = false

    @ObservedObject private var controller: Controller = Controller()

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Incoming transactions")) {
                    ForEach(controller.incomingBudgets) { budget in
                        let transactions = controller.incomingTransactions(for: budget.id)
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: budget)) {
                            AmountListItem(label: budget.name, amount: transactions.totalAmount)
                        }
                    }
                }

                Section(header: Text("Outgoing transactions")) {
                    ForEach(controller.expensesBudgets) { budget in
                        let transactions = controller.outgoingTransactions(for: budget.id)
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: budget)) {
                            AmountListItem(label: budget.name, amount: transactions.totalAmount)
                        }
                    }
                }
            }
        }
    }

    // MARK: Private factory methods

    private func makeTransactionsView(with transactions: [Transaction], for budget: Budget) -> some View {
        TransactionsView(transactions: transactions)
            .navigationTitle(Text(budget.name))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add transaction") {
                        isInsertTransactionsPresented = true
                    }
                }
            }
            .sheet(isPresented: $isInsertTransactionsPresented, onDismiss: nil) {
                InsertTransactionsView(budget: budget)
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
