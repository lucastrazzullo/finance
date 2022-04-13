//
//  BudgetsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct BudgetsListView<Destination: View, ViewModel: BudgetsListViewModel>: View {

    @ViewBuilder var destination: (Budget) -> Destination
    @ObservedObject var viewModel: ViewModel

    @State private var deleteBudgetError: DomainError?
    @State private var addNewBudgetError: DomainError?
    @State private var addNewBudgetIsPresented: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Budgets")) {
                    ForEach(viewModel.listBudgets) { budget in
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

                    if let error = deleteBudgetError ?? addNewBudgetError {
                        InlineErrorView(error: error)
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
                        title: viewModel.listTitle,
                        subtitle: viewModel.listSubtitle
                    )
                }
            })
            .onAppear(perform: { Task { try? await viewModel.fetch() }})
            .sheet(isPresented: $addNewBudgetIsPresented) {
                NewBudgetView(year: viewModel.listYear) { budget in
                    do {
                        try await viewModel.add(budget: budget)
                        addNewBudgetError = nil
                        addNewBudgetIsPresented = false
                    } catch {
                        addNewBudgetError = error as? DomainError
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct BudgetsListView_Previews: PreviewProvider {
    static let storageProvider = try! MockStorageProvider()
    static var previews: some View {
        BudgetsListView(
            destination: { budget in BudgetView(budget: budget, storageProvider: storageProvider) },
            viewModel: MockBudgetsListViewModel(year: Mocks.year)
        )
    }
}

private final class MockBudgetsListViewModel: BudgetsListViewModel {
    let listYear: Int
    let listTitle: String = "Title"
    let listSubtitle: String = "Subtitle"
    var listBudgets: [Budget] = []

    init(year: Int) {
        listYear = year
    }

    func fetch() async {
        listBudgets = Mocks.budgets
    }

    func add(budget: Budget) async throws {
        listBudgets.append(budget)
    }

    func delete(budgetsAt indices: IndexSet) async throws {
        listBudgets.remove(atOffsets: indices)
    }
}
