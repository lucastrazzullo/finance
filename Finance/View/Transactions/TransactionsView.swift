//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/01/2022.
//

import SwiftUI

struct TransactionsView: View {

    private struct InsertTransactionItem: Identifiable {

        var id: UUID {
            return budgetSliceId
        }

        let budget: Budget
        let budgetSliceId: BudgetSlice.ID
    }

    private final class Controller: ObservableObject {

        private let transactions: [Transaction]

        lazy var budgets: [Budget] = {
            return budgets(for: transactions)
        }()

        init(transactions: [Transaction]) {
            self.transactions = transactions
        }

        // MARK: Internal methods

        func budget(with id: Budget.ID) -> Budget? {
            allBudgets().first(where: { $0.id == id })
        }

        func slices(forBudgetWith id: Budget.ID) -> [BudgetSlice] {
            return budget(with: id)?.slices.all() ?? []
        }

        func transactions(forBudgetWith id: Budget.ID) -> [Transaction] {
            return transactions
                .filter({ $0.budgetId == id })
        }

        func transactions(forBudgetWith id: Budget.ID, sliceId: BudgetSlice.ID) -> [Transaction] {
            return transactions(forBudgetWith: id)
                .filter({ $0.budgetSliceId == sliceId })
        }

        // MARK: Private methods

        private func budgets(for transactions: [Transaction]) -> [Budget] {
            transactions
                .map(\.budgetId)
                .removeDuplicates()
                .compactMap(budget(with:))
        }

        private func allBudgets() -> [Budget] {
            Mocks.budgets.all()
        }
    }

    @State private var insertTransactions: InsertTransactionItem?

    @ObservedObject private var controller: Controller

    var body: some View {
        List {
            ForEach(controller.budgets) { budget in
                Section(header: SectionHeaderView(name: budget.name, transactions: controller.transactions(forBudgetWith: budget.id))) {
                    ForEach(controller.slices(forBudgetWith: budget.id)) { slice in
                        let transactions = controller.transactions(forBudgetWith: budget.id, sliceId: slice.id)
                        Section(header: SectionHeaderView(name: slice.name, transactions: transactions)) {
                            ForEach(transactions) { transaction in
                                TransactionListItem(transaction: transaction)
                            }

                            HStack {
                                Spacer()
                                Button(action: {
                                    insertTransactions = InsertTransactionItem(budget: budget, budgetSliceId: slice.id)
                                }) {
                                    Label("Add Transaction", systemImage: "plus").font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $insertTransactions, onDismiss: {
            insertTransactions = nil
        }) { object in
            InsertTransactionsView(budget: object.budget, initialSliceId: object.budgetSliceId, initialInsertionPresented: true)
        }
    }

    init(transactions: [Transaction]) {
        self.controller = Controller(transactions: transactions)
    }
}

private struct SectionHeaderView: View {

    let name: String
    let amount: MoneyValue

    var body: some View {
        AmountListItem(label: name, amount: amount)
    }

    init(name: String, transactions: [Transaction]) {
        self.name = name
        self.amount = transactions.totalAmount
    }
}

// MARK: - Previews

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        var transactions = [Transaction]()
        transactions.append(contentsOf: Mocks.outgoingTransactions)
        transactions.append(contentsOf: Mocks.incomingTransactions)

        return NavigationView {
            TransactionsView(transactions: transactions)
                .navigationTitle("Transactions")
        }
    }
}
