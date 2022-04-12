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

    let onAppear: () async -> Void
    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(budgets) { budget in
                        NavigationLink(destination: destination(budget)) {
                            HStack {
                                let viewModel = BudgetViewModel(budget: budget)
                                Label(viewModel.name, systemImage: viewModel.iconSystemName)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.body.bold())
                                    .accentColor(.secondary)
                                Spacer()
                                AmountView(amount: viewModel.amount)
                            }
                            .padding(.vertical, 8)
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
            .listStyle(.inset)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: title,
                        subtitle: subtitle
                    )
                }
            })
            .onAppear(perform: { Task { await onAppear() }})
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = try! MockStorageProvider(year: Mocks.year)
    static var previews: some View {
        BudgetsListView(
            destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
            title: "Title",
            subtitle: "Subtitle",
            budgets: Mocks.budgets,
            error: nil,
            onAppear: {},
            onAdd: {},
            onDelete: { _ in }
        )
    }
}
