//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<ViewModel: BudgetsListViewModel, Item: View>: View {

    @ObservedObject var viewModel: ViewModel

    @ViewBuilder var item: (Budget) -> Item

    @State var deleteBudgetError: DomainError?
    @State var addNewBudgetIsPresented: Bool = false

    var body: some View {
        List {
            Section(header: Text("Budgets")) {
                ForEach(viewModel.budgets) { budget in
                    item(budget)
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.budgetLink)
                }
                .onDelete { offsets in
                    Task {
                        do {
                            try await viewModel.delete(budgetsAt: offsets)
                            deleteBudgetError = nil
                        } catch {
                            deleteBudgetError = error as? DomainError
                        }
                    }
                }

                Button(action: { addNewBudgetIsPresented = true }) {
                    Label("Add", systemImage: "plus")
                        .accessibilityIdentifier(AccessibilityIdentifier.BudgetsListView.addBudgetButton)
                }
            }
        }
        .listStyle(.inset)
        .sheet(isPresented: $addNewBudgetIsPresented) {
            NewBudgetView(year: viewModel.year, onSubmit: { budget in
                try await viewModel.add(budget: budget)
                addNewBudgetIsPresented = false
            })
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider()
    static var previews: some View {
        BudgetsListView(
            viewModel: MockViewModel(),
            item: { budget in
                BudgetsListItem(budget: budget)
            }
        )
    }
}

private final class MockViewModel: BudgetsListViewModel {

    let year: Int = Mocks.year
    let budgets: [Budget] = Mocks.budgets

    func add(budget: Budget) async throws {
    }

    func delete(budgetsAt offsets: IndexSet) async throws {
    }
}
