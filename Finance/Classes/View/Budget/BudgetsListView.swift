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
                    Task {
                        await viewModel.delete(budgetsAt: offsets)
                    }
                }

                Button(action: { viewModel.isAddNewBudgetPresented = true }) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                }

                if let error = viewModel.deleteBudgetError {
                    InlineErrorView(error: error)
                }
            }
        }
        .listStyle(.inset)
        .sheet(isPresented: $viewModel.isAddNewBudgetPresented) {
            NewBudgetView(year: viewModel.year, onSubmit: viewModel.add(budget:))
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetsListView(
            viewModel: .init(dataProvider: MockBudgetsListDataProvider(budgets: Mocks.budgets)),
            item: { budget in
                BudgetsListItem(budget: budget)
            }
        )
    }
}
