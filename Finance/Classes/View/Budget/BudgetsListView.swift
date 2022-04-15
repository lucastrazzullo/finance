//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<ViewModel: BudgetsListViewModel>: View {

    @Environment(\.repository) private var repository

    @ObservedObject private var viewModel: ViewModel

    @State private var deleteBudgetError: DomainError?
    @State private var addNewBudgetIsPresented: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(viewModel.budgets) { budget in
                        let viewModel = RepositoryBackedBudgetViewModel(budget: budget, repository: repository)
                        NavigationLink(destination: { BudgetView(viewModel: viewModel) }) {
                            HStack {
                                Label(viewModel.name, systemImage: viewModel.systemIcon.rawValue)
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
                    .onDelete { indices in
                        Task {
                            do {
                                try await viewModel.delete(budgetsAt: indices)
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: viewModel.title,
                        subtitle: viewModel.subtitle
                    )
                }
            })
            .onAppear(perform: { Task { try? await viewModel.fetch() }})
            .sheet(isPresented: $addNewBudgetIsPresented) {
                NewBudgetView(year: viewModel.year) { budget in
                    try await viewModel.add(budget: budget)
                    addNewBudgetIsPresented = false
                }
            }
        }
    }

    // MARK: Object life cycle

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsListView(viewModel: MockBudgetsListViewModel(year: Mocks.year))
    }
}

final class MockBudgetsListViewModel: BudgetsListViewModel {
    let year: Int
    let title: String = "Title"
    let subtitle: String = "Subtitle"
    var budgets: [Budget] = []

    init(year: Int) {
        self.year = year
    }

    func fetch() async {
        budgets = Mocks.budgets
    }

    func add(budget: Budget) async throws {
        budgets.append(budget)
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        budgets.remove(atOffsets: indices)
    }
}
