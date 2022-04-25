//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<Item: View>: View {

    @ObservedObject var viewModel: BudgetsListViewModel

    @ViewBuilder var item: (Budget) -> Item

    var body: some View {
        List {
            Section(header: Text("Budgets")) {
                ForEach(viewModel.budgets) { budget in
                    item(budget)
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.budgetLink)
                }
                .onDelete { offsets in
                    Task { await viewModel.delete(budgetsAt: offsets) }
                }

                Button(action: { viewModel.addNewBudgetIsPresented = true }) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                }
            }
        }
        .listStyle(.inset)
        .sheet(isPresented: $viewModel.addNewBudgetIsPresented) {
            NewBudgetView(year: viewModel.year, onSubmit: viewModel.add(budget:))
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetsListView(
            viewModel: .init(
                year: Mocks.year,
                budgets: Mocks.budgets,
                storageProvider: MockStorageProvider(),
                delegate: nil
            ),
            item: { budget in
                BudgetsListItem(budget: budget)
            }
        )
    }
}
