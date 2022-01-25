//
//  BudgetsView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetsView: View {

    @State private var isAddNewBudgetPresented: Bool = false
    @State private var addNewBudgetError: DomainError?

    @ObservedObject private var controller: BudgetsController

    var body: some View {
        List {
            ForEach(controller.budgets.list) { budget in
                if let budgetProvider = controller.budgetProvider {
                    NavigationLink(destination: BudgetView(budget: budget, budgetProvider: budgetProvider)) {
                        AmountListItem(label: budget.name, amount: budget.amount)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            controller.delete(budget: budget) { result in
                                if case let .failure(error) = result {
                                    addNewBudgetError = error
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isAddNewBudgetPresented = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddNewBudgetPresented) {
            NewBudgetView() { budget in
                controller.save(budget: budget) { result in
                    switch result {
                    case .success:
                        isAddNewBudgetPresented = false
                    case .failure(let error):
                        addNewBudgetError = error
                    }
                }
            }
            .sheet(item: $addNewBudgetError) { presentedError in
                ErrorView(error: presentedError, options: [.retry], onSubmit: { option in
                    addNewBudgetError = nil
                })
            }
        }
        .onAppear(perform: controller.fetch)
    }

    init(budgetProvider: BudgetProvider) {
        self.controller = BudgetsController(budgetProvider: budgetProvider)
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static let budgetStorageProvider = MockBudgetProvider()
    static var previews: some View {
        NavigationView {
            BudgetsView(budgetProvider: budgetStorageProvider).navigationTitle("Budgets")
        }
    }
}
