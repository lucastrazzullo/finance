//
//  AddTransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 15/04/2022.
//

import SwiftUI

struct AddTransactionsView: View {

    @State private var transactions: [Transaction] = []
    @State private var addNewTransactionPresented: Bool = false

    @State private var submitError: DomainError?

    let budgets: [Budget]
    let onSubmit: ([Transaction]) async throws -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(budgets(for: transactions), id: \.self) { budget in
                    let budgetTransactions = transactions(forBudgetWith: budget.id)
                    let headerViewModel = SectionHeader.ViewModel(budget: budget, amount: budgetTransactions.totalAmount)
                    Section(header: SectionHeader(viewModel: headerViewModel)) {
                        ForEach(budgetTransactions, id: \.self) { transaction in
                            let sliceName = sliceName(for: transaction.budgetSliceId, inBudgetWith: budget.id) ?? "--"
                            let viewModel = TransactionItem.ViewModel(sliceName: sliceName, date: transaction.date, amount: transaction.amount)
                            TransactionItem(viewModel: viewModel)
                        }
                        .onDelete { indices in
                            transactions.remove(atOffsets: indices)
                        }
                    }
                }

                Section {
                    Button(action: { addNewTransactionPresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical)
                }

                Section(header: SectionHeader(viewModel: .init(icon: .none, label: "Total", amount: transactions.totalAmount))) {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button(action: save) {
                        Text("Save")
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                }
            }
            .listStyle(.inset)
            .navigationTitle("Add transactions")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $addNewTransactionPresented) {
                NewTransactionView(budgets: budgets, onSubmit: add(transaction:))
            }
        }
    }

    // MARK: Private helper methods

    private func add(transaction: Transaction) async throws {
        transactions.append(transaction)
        addNewTransactionPresented = false
    }

    private func save() {
        Task {
            do {
                try await onSubmit(transactions)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }

    private func budgets(for transactions: [Transaction]) -> [Budget] {
        let transactionSliceIdentifiers = Set(transactions.map(\.budgetSliceId))
        return budgets
            .filter { budget in
                let budgetSliceIdentifiers = Set(budget.slices.map(\.id))
                return !transactionSliceIdentifiers.intersection(budgetSliceIdentifiers).isEmpty
            }
    }

    private func transactions(forBudgetWith id: Budget.ID) -> [Transaction] {
        return transactions.filter { transaction in
            guard let budget = budgets.with(identifier: id) else {
                return false
            }
            return budget.slices.map(\.id).contains(transaction.budgetSliceId)
        }
    }

    private func sliceName(for sliceId: BudgetSlice.ID, inBudgetWith id: Budget.ID) -> String? {
        return budgets
            .with(identifier: id)?
            .slices
            .with(identifier: sliceId)?
            .name
    }
}

private struct SectionHeader: View {

    struct ViewModel: Hashable {
        let icon: SystemIcon?
        let label: String
        let amount: MoneyValue

        init(icon: SystemIcon?, label: String, amount: MoneyValue) {
            self.icon = icon
            self.label = label
            self.amount = amount
        }

        init(budget: Budget, amount: MoneyValue) {
            self.icon = budget.icon
            self.label = budget.name
            self.amount = amount
        }
    }

    let viewModel: ViewModel

    var body: some View {
        HStack {
            if let systemIcon = viewModel.icon {
                Image(systemName: systemIcon.rawValue)
            }
            Text(viewModel.label)
            Spacer()
            AmountView(amount: viewModel.amount)
        }
    }
}

private struct TransactionItem: View {

    struct ViewModel {
        let sliceName: String
        let date: Date
        let amount: MoneyValue
    }

    let viewModel: ViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.sliceName).font(.headline)
                Text(viewModel.date, style: .date).font(.caption)
            }

            Spacer()

            AmountView(amount: viewModel.amount)
        }
        .padding(.vertical, 8)
    }
}

struct AddTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionsView(budgets: Mocks.budgets) { _ in }
    }
}
