//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView: View {

    @State private var deleteBudgetError: DomainError?
    @State private var addNewBudgetIsPresented: Bool = false

    let year: Int
    let name: String
    let budgets: [Budget]

    let addBudget: (Budget) async throws -> Void
    let deleteBudgets: (Set<Budget.ID>) async throws -> Void
    let addSliceToBudget: (BudgetSlice, Budget.ID) async throws -> Void
    let deleteSlices: (Set<BudgetSlice.ID>, Budget.ID) async throws -> Void
    let updateNameAndIcon: (String, SystemIcon, Budget.ID) async throws -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(budgets) { budget in
                        NavigationLink(destination: {
                            BudgetView(
                                budget: budget,
                                addSliceToBudget: addSliceToBudget,
                                deleteSlices: deleteSlices,
                                updateNameAndIcon: updateNameAndIcon
                            )
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
                        Task { await delete(offsets: offsets) }
                    }

                    Button(action: { addNewBudgetIsPresented = true }) {
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
                        title: String(year),
                        subtitle: name
                    )
                }
            })
            .sheet(isPresented: $addNewBudgetIsPresented) {
                NewBudgetView(year: year, onSubmit: add(budget:))
            }
        }
    }

    // MARK: Private helper methods

    private func add(budget: Budget) async throws {
        try await addBudget(budget)
        addNewBudgetIsPresented = false
    }

    private func delete(offsets: IndexSet) async {
        do {
            let identifiers = budgets.at(offsets: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await deleteBudgets(identifiersSet)
            deleteBudgetError = nil
        } catch {
            deleteBudgetError = error as? DomainError
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let overview = Mocks.overview
    static var previews: some View {
        BudgetsListView(
            year: overview.year,
            name: overview.name,
            budgets: overview.budgets,
            addBudget: { _ in },
            deleteBudgets: { _ in},
            addSliceToBudget: { _, _ in },
            deleteSlices: { _, _ in },
            updateNameAndIcon: { _, _, _ in }
        )
    }
}
