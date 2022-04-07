//
//  BudgetList.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetList<Destination: View>: View {

    @ViewBuilder let destination: (Budget) -> Destination

    let budgets: [Budget]
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            Section(header: Text("Budgets")) {
                ForEach(budgets) { budget in
                    NavigationLink(destination: destination(budget)) {
                        AmountListItem(label: budget.name, amount: budget.amount)
                    }
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

struct BudgetList_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetList(destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider)},
                   budgets: Mocks.budgets,
                   error: nil,
                   onAdd: {},
                   onDelete: { _ in })
    }
}
