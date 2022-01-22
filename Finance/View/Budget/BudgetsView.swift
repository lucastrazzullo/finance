//
//  BudgetsView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetsView: View {

    final class Controller: ObservableObject {

        enum ControllerError: Error {
            case entityNotFound
        }

        @Published var budgets: [Budget] = []

        let storageProvider: BudgetStorageProvider

        private var budgetEntities: [BudgetEntity] {
            didSet {
                budgets = budgetEntities.compactMap(Budget.with(budgetEntity:))
            }
        }

        init(storageProvider: BudgetStorageProvider) {
            self.storageProvider = storageProvider
            self.budgetEntities = []
        }

        func fetch() {
            storageProvider.fetchBudgetEntities { [weak self] result in
                switch result {
                case .success(let budgets):
                    self?.budgetEntities = budgets
                case .failure:
                    break
                }
            }
        }

        func save(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            storageProvider.save(budget: budget) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        }

        func delete(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let entity = budgetEntities.first(where: { $0.identifier == budget.id }) else {
                completion(.failure(ControllerError.entityNotFound))
                return
            }

            storageProvider.delete(budgetEntity: entity) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        }
    }

    @State private var isInsertBudgetPresented: Bool = false
    @State private var newBudgetName: String = ""
    @State private var newBudgetAmount: String = ""

    @ObservedObject private var controller: Controller

    var body: some View {
        List {
            ForEach(controller.budgets) { budget in
                NavigationLink(destination: BudgetView(budget: budget)) {
                    AmountListItem(label: budget.name, amount: budget.amount)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        controller.delete(budget: budget, completion: { _ in })
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isInsertBudgetPresented = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isInsertBudgetPresented, onDismiss: {}) {
            Form {
                Section(header: Text("New Budget")) {
                    TextField("Name", text: $newBudgetName)
                    InsertAmountField(amountValue: $newBudgetAmount, title: "Monthly Amount", prompt: nil)
                }

                Section {
                    Button("Save") {
                        let amount = MoneyValue.string(newBudgetAmount) ?? .zero
                        let budget = Budget(id: UUID(), name: newBudgetName, amount: amount)
                        controller.save(budget: budget) { result in
                            switch result {
                            case .success:
                                isInsertBudgetPresented = false
                            case .failure:
                                break
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: controller.fetch)
    }

    init(storageProvider: BudgetStorageProvider) {
        self.controller = Controller(storageProvider: storageProvider)
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static var previews: some View {
        let storageProvider = StorageProvider()
        NavigationView {
            BudgetsView(storageProvider: storageProvider.budgetProvider).navigationTitle("Budgets")
        }
    }
}
