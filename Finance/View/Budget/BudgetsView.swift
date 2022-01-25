//
//  BudgetsView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetsView: View {

    enum Sheet: Identifiable {
        case error(DomainError)
        case addNewBudget

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .addNewBudget:
                return "newBudget"
            }
        }
    }

    @State private var sheet: Sheet?

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
                                    sheet = .error(error)
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
                Button(action: { sheet = .addNewBudget }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(item: $sheet, onDismiss: nil) { presentingSheet in
            switch presentingSheet {
            case .error(let error):
                makeErrorView(error: error)
            case .addNewBudget:
                makeAddNewBudgetView()
            }
        }
        .onAppear(perform: controller.fetch)
    }

    @ViewBuilder private func makeErrorView(error: DomainError) -> some View {
        ErrorView(error: error, options: [.retry], onSubmit: { option in
            sheet = .addNewBudget
        })
    }

    @ViewBuilder private func makeAddNewBudgetView() -> some View {
        NewBudgetView() { budget in
            controller.save(budget: budget) { result in
                switch result {
                case .success:
                    sheet = nil
                case .failure(let error):
                    sheet = .error(error)
                }
            }
        }
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
