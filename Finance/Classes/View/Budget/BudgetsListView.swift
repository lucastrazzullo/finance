//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<Header: ToolbarContent>: View {

    @ToolbarContentBuilder var header: () -> Header
    @ObservedObject var viewModel: BudgetsListViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(viewModel.budgets) { budget in
                        NavigationLink(destination: {
                            BudgetView(viewModel: BudgetViewModel(budget: budget, handler: viewModel.handler))
                        }, label: {
                            HStack {
                                Label(budget.name, systemImage: budget.icon.rawValue)
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.body.bold())
                                    .accentColor(.secondary)
                                Spacer()
                                AmountView(amount: budget.amount)
                            }
                            .padding(.vertical, 8)
                        })
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.budgetLink)
                    }
                    .onDelete { offsets in
                        Task { await viewModel.delete(offsets: offsets) }
                    }

                    Button(action: { viewModel.addNewBudgetIsPresented = true }) {
                        Label("Add", systemImage: "plus")
                            .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                    }
                }
            }
            .listStyle(.inset)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .toolbar(content: header)
            .sheet(isPresented: $viewModel.addNewBudgetIsPresented) {
                NewBudgetView(year: viewModel.year, onSubmit: viewModel.add(budget:))
            }
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsListView(
            header: {
                ToolbarItem {
                    Text("Header")
                }
            },
            viewModel: .init(
                year: Mocks.year,
                title: "Title",
                budgets: Mocks.budgets,
                handler: nil
            )
        )
    }
}
