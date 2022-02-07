//
//  TransactionsView.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import SwiftUI

struct CategorisedTransactionsView: View {

    final class Controller: ObservableObject {

        private let transactions: [Transaction] = Mocks.incomingTransactions

        @Published var budgets: [Budget] = []

        private(set) var budgetProvider: ReportProvider?

        init(budgetProvider: ReportProvider) {
            self.budgetProvider = budgetProvider
            self.budgets = []
        }

        // MARK: Public methods

        func fetch() {
            Task {
                do {
                    let report = try await budgetProvider?.fetchReport()
                    let budgets = report?.budgets ?? []
                    DispatchQueue.main.async { [weak self] in
                        self?.budgets = budgets
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }

        func transactions(for budgetId: Budget.ID, filteredBy monthIdentifier: Int) -> [Transaction] {
            transactions
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

        private func incomingBudget(with id: Budget.ID) -> Budget? {
            budgets.first(where: { $0.id == id })
        }
    }

    @State private var isInsertTransactionsPresented: Bool = false
    @State private var selectedMonthInbdex: Int = Months.monthIndex(for: Months.currentMonthIdentifier)

    @ObservedObject private var controller: Controller

    var body: some View {
        VStack(spacing: 10) {

            List {
                let selectedMonthIdentifier = Months.monthIdentifier(by: selectedMonthInbdex)
                ForEach(controller.budgets) { budget in
                    let transactions = controller.transactions(for: budget.id, filteredBy: selectedMonthIdentifier)
                    NavigationLink(destination: makeTransactionsView(with: transactions, for: budget)) {
                        AmountListItem(label: budget.name, amount: transactions.totalAmount)
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
        .onAppear(perform: controller.fetch)
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

    init(budgetProvider: ReportProvider) {
        self.controller = Controller(budgetProvider: budgetProvider)
    }
}

// MARK: - Previews

struct CategorisedTransactionsView_Previews: PreviewProvider {
    static let budgetStorageProvider = ReportProvider(storageProvider: MockBudgetStorageProvider())
    static var previews: some View {
        NavigationView {
            CategorisedTransactionsView(budgetProvider: budgetStorageProvider)
                .navigationTitle("Transactions 2022")
        }
    }
}
