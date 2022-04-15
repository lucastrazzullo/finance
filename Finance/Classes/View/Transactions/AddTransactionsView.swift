//
//  AddTransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 15/04/2022.
//

import SwiftUI

struct AddTransactionsView: View {

    private let transactions: [Transaction] = Mocks.transactions
    private let slices: [BudgetSlice] = Mocks.houseSlices + Mocks.groceriesSlices
    private let budgets: [Budget] = Mocks.budgets

    var body: some View {
        NavigationView {
            List {
                ForEach(budgets(for: transactions), id: \.self) { budget in
                    let headerViewModel = SectionHeader.ViewModel(budget: budget)
                    Section(header: SectionHeader(viewModel: headerViewModel)) {
                        ForEach(transactions(for: budget.id), id: \.self) { transaction in
                            let sliceName = sliceName(for: transaction.budgetSliceId) ?? "--"
                            let viewModel = TransactionItem.ViewModel(sliceName: sliceName, date: transaction.date, amount: transaction.amount)
                            TransactionItem(viewModel: viewModel)
                        }
                    }
                }

                Section(header: SectionHeader(viewModel: .init(icon: .none, label: "Total", amount: .value(2000)))) {

                    Button(action: {}) {
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
        }
    }

    // MARK: Private helper methods

    private func budgets(for transactions: [Transaction]) -> [Budget] {
        let transactionSliceIdentifiers = Set(transactions.map(\.budgetSliceId))
        return budgets
            .filter { budget in
                let budgetSliceIdentifiers = Set(budget.slices.map(\.id))
                return !transactionSliceIdentifiers.intersection(budgetSliceIdentifiers).isEmpty
            }
    }

    private func transactions(for budgetId: Budget.ID) -> [Transaction] {
        return transactions.filter { transaction in
            guard let budget = budgets.first(where: { $0.id == budgetId }) else {
                return false
            }
            return budget.slices.map(\.id).contains(transaction.budgetSliceId)
        }
    }

    private func sliceName(for sliceId: BudgetSlice.ID) -> String? {
        return slices.first(where: { $0.id == sliceId })?.name
    }
}

private struct SectionHeader: View {

    struct ViewModel: Hashable {
        let icon: Icon
        let label: String
        let amount: MoneyValue

        init(icon: Icon, label: String, amount: MoneyValue) {
            self.icon = icon
            self.label = label
            self.amount = amount
        }

        init(budget: Budget) {
            self.icon = budget.icon
            self.label = budget.name
            self.amount = budget.amount
        }
    }

    let viewModel: ViewModel

    var body: some View {
        HStack {
            if case .system(let systemIcon) = viewModel.icon {
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
            VStack(alignment: .leading) {
                Text(viewModel.sliceName).font(.headline)
                Text(viewModel.date, style: .date).font(.caption)
            }

            Spacer()

            AmountView(amount: viewModel.amount)
        }
    }
}

struct AddTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionsView()
    }
}
