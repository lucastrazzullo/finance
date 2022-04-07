//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<ListItem: View>: View {

    @ViewBuilder let listItem: (Budget) -> ListItem

    let budgets: [Budget]
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            Section(header: Text("Budgets")) {
                ForEach(budgets) { budget in
                    listItem(budget)
                        .accessibilityIdentifier(AccessibilityIdentifier.ReportView.budgetLink)
                }
                .onDelete(perform: onDelete)

                if let error = error {
                    InlineErrorView(error: error)
                }

                Button(action: onAdd) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.ReportView.addBudgetButton)
                }
            }
        }
        .listStyle(InsetListStyle())
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetsListView(listItem: { budget in AmountListItem(label: budget.name, amount: budget.amount) },
                        budgets: Mocks.budgets,
                        error: nil,
                        onAdd: {},
                        onDelete: { _ in })
    }
}
