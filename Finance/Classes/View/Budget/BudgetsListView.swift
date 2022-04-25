//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<Header: ToolbarContent>: View {

    @Environment(\.storageProvider) private var storageProvider
    @ObservedObject var viewModel: BudgetsListViewModel
    @ToolbarContentBuilder var header: () -> Header

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(viewModel.budgets) { budget in
                        NavigationLink(destination: makeBudgetsListView(budget: budget), label: {
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
                        Task { await viewModel.delete(budgetsAt: offsets) }
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

    // MARK: Private builder methods

    @ViewBuilder private func makeBudgetsListView(budget: Budget) -> some View {
        let viewModel = BudgetViewModel(
            budget: budget,
            storageProvider: storageProvider,
            delegate: viewModel
        )

        BudgetView(viewModel: viewModel)
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetsListView(
            viewModel: .init(
                year: Mocks.year,
                title: "Title",
                budgets: Mocks.budgets,
                storageProvider: MockStorageProvider(),
                delegate: nil
            ),
            header: {
                ToolbarItem {
                    Text("Header")
                }
            }
        )
    }
}
