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

                Button(action: viewModel.addBudgets) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                }

                if let error = viewModel.deleteBudgetError {
                    InlineErrorView(error: error)
                }
            }
        }
        .listStyle(.inset)
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let budgets = Mocks.expenseBudgets
    static var previews: some View {
        BudgetsListView(
            viewModel: .init(
                budgets: budgets,
                addBudgets: {},
                deleteBudgets: { _ in }
            ),
            item: { budget in BudgetsListItem(budget: budget) }
        )
    }
}
