//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<Destination: View>: View {

    @ViewBuilder var destination: (Budget) -> Destination

    let title: String
    let subtitle: String
    let budgets: [Budget]
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(budgets) { budget in
                        NavigationLink(destination: destination(budget)) {
                            AmountListItem(label: budget.name, amount: budget.amount)
                        }
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.budgetLink)
                    }
                    .onDelete(perform: onDelete)

                    if let error = error {
                        InlineErrorView(error: error)
                    }

                    Button(action: onAdd) {
                        Label("Add", systemImage: "plus")
                            .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                    }
                }
            }
            .listStyle(InsetListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .toolbar(content: {
                DefaultToolbar(
                    title: title,
                    subtitle: subtitle
                )
            })
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let year = 2022
    static let storageProvider = MockStorageProvider(overviewYear: year)
    static var previews: some View {
        BudgetsListView(
            destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
            title: "Title",
            subtitle: "Subtitle",
            budgets: Mocks.budgets(withYear: year),
            error: nil,
            onAdd: {},
            onDelete: { _ in }
        )
    }
}
