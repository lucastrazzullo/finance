//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import SwiftUI

struct CategorisedTransactionsView: View {

    final class Controller: ObservableObject {

        private let incomingTransactions: [Transaction] = Mocks.incomingTransactions
        private let outgoingTransactions: [Transaction] = Mocks.outgoingTransactions

        let allIncomingBudgets: [Budget] = Mocks.budgets
        let allExpensesBudgets: [Budget] = Mocks.budgets

        func incomingTransactions(for budgetId: Budget.ID, filteredBy monthIdentifier: Int) -> [Transaction] {
            incomingTransactions
                .filter { $0.budgetId == budgetId }
                .filter { transaction in
                    let monthComponent = Calendar.current.component(.month, from: transaction.date)
                    return monthComponent == monthIdentifier
                }
        }

        func outgoingTransactions(for budgetId: Budget.ID, filteredBy monthIdentifier: Int) -> [Transaction] {
            outgoingTransactions
                .filter { $0.budgetId == budgetId }
                .filter { transaction in
                    let monthComponent = Calendar.current.component(.month, from: transaction.date)
                    return monthComponent == monthIdentifier
                }
        }

        // MARK: Private methods

        private func incomingBudgets(for transactions: [Transaction]) -> [Budget] {
            transactions
                .map(\.budgetId)
                .removeDuplicates()
                .compactMap(incomingBudget(with:))
        }

        private func expensesBudgets(for transactions: [Transaction]) -> [Budget] {
            transactions
                .map(\.budgetId)
                .removeDuplicates()
                .compactMap(expensesBudget(with:))
        }

        private func incomingBudget(with id: Budget.ID) -> Budget? {
            allIncomingBudgets.first(where: { $0.id == id })
        }

        private func expensesBudget(with id: Budget.ID) -> Budget? {
            allExpensesBudgets.first(where: { $0.id == id })
        }
    }

    @State private var isInsertTransactionsPresented: Bool = false
    @State private var selectedMonthInbdex: Int = Months.monthIndex(for: Months.currentMonthIdentifier)

    @ObservedObject private var controller: Controller = Controller()

    var body: some View {
        VStack(spacing: 10) {

            List {
                Section(header: Text("Incoming transactions")) {
                    let selectedMonthIdentifier = Months.monthIdentifier(by: selectedMonthInbdex)
                    ForEach(controller.allIncomingBudgets) { budget in
                        let transactions = controller.incomingTransactions(for: budget.id, filteredBy: selectedMonthIdentifier)
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: budget)) {
                            AmountListItem(label: budget.name, amount: transactions.totalAmount)
                        }
                    }
                }

                Section(header: Text("Outgoing transactions")) {
                    let selectedMonthIdentifier = Months.monthIdentifier(by: selectedMonthInbdex)
                    ForEach(controller.allExpensesBudgets) { budget in
                        let transactions = controller.outgoingTransactions(for: budget.id, filteredBy: selectedMonthIdentifier)
                        NavigationLink(destination: makeTransactionsView(with: transactions, for: budget)) {
                            AmountListItem(label: budget.name, amount: transactions.totalAmount)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Picker("Month", selection: $selectedMonthInbdex) {
                        ForEach(Months.allMonths.enumerated().map(\.offset), id: \.self) { index in
                            Text(Months.allMonths[index])
                        }
                    }

                    Image(systemName: "calendar")
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
                .navigationTitle("Transactions 2022")
        }
    }
}
