//
//  BudgetsView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetsView: View {

    final class Controller: ObservableObject {

        @Published var budgets: [Budget] = []

        private(set) weak var budgetProvider: BudgetProvider?

        init(budgetProvider: BudgetProvider) {
            self.budgetProvider = budgetProvider
            self.budgets = []
        }

        func fetch() {
            budgetProvider?.fetchBudgets { [weak self] result in
                switch result {
                case .success(let budgets):
                    self?.budgets = budgets
                case .failure:
                    break
                }
            }
        }

        // MARK: Internal methods

        func save(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            budgetProvider?.add(budget: budget) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        }

        func delete(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            budgetProvider?.delete(budget: budget) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        }
    }

    @State private var isInsertNewBudgetPresented: Bool = false
    @State private var newBudgetName: String = ""
    @State private var newBudgetAmount: String = ""
    @State private var newBudgetSlices: [BudgetSlice] = []

    @State private var isInsertNewBudgetSlicePresented: Bool = false
    @State private var newBudgetSliceName: String = ""
    @State private var newBudgetSliceAmount: String = ""

    @ObservedObject private var controller: Controller

    var body: some View {
        List {
            ForEach(controller.budgets) { budget in
                if let budgetProvider = controller.budgetProvider {
                    NavigationLink(destination: BudgetView(budget: budget, budgetProvider: budgetProvider)) {
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
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isInsertNewBudgetPresented = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isInsertNewBudgetPresented, onDismiss: {
            newBudgetName = ""
            newBudgetAmount = ""
            newBudgetSlices = []
        }, content: {
            Form {
                Section(header: Text("New Budget")) {
                    TextField("Name", text: $newBudgetName)

                    if newBudgetSlices.isEmpty {
                        InsertAmountField(amountValue: $newBudgetAmount, title: "Monthly Amount", prompt: nil)
                    } else {
                        AmountCollectionItem(title: "Monthly total",
                                             caption: nil,
                                             amount: newBudgetSlices.totalAmount,
                                             color: .green)
                    }
                }

                Section(header: Text("Slices")) {
                    if !newBudgetSlices.isEmpty {
                        List {
                            ForEach(newBudgetSlices) { slice in
                                AmountListItem(label: slice.name, amount: slice.amount)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            newBudgetSlices.removeAll(where: { $0.id == slice.id })
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    Button(action: { isInsertNewBudgetSlicePresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }

                Section {
                    Button("Save") {
                        let budget: Budget
                        if newBudgetSlices.isEmpty, let amount = MoneyValue.string(newBudgetAmount) {
                            budget = Budget(id: .init(), name: newBudgetName, amount: amount)
                        } else if !newBudgetSlices.isEmpty {
                            budget = Budget(id: .init(), name: newBudgetName, slices: newBudgetSlices)
                        } else {
                            return
                        }

                        controller.save(budget: budget) { result in
                            switch result {
                            case .success:
                                isInsertNewBudgetPresented = false
                            case .failure:
                                break
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isInsertNewBudgetSlicePresented, onDismiss: {
                newBudgetSliceName = ""
                newBudgetSliceAmount = ""
            }, content: {
                Form {
                    Section(header: Text("New Budget Slice")) {
                        TextField("Name", text: $newBudgetSliceName)
                        InsertAmountField(amountValue: $newBudgetSliceAmount, title: "Monthly Amount", prompt: nil)
                    }

                    Section {
                        Button("Save") {
                            guard let amount = MoneyValue.string(newBudgetSliceAmount) else {
                                return
                            }

                            newBudgetSlices.append(BudgetSlice(id: .init(), name: newBudgetSliceName, amount: amount))
                            isInsertNewBudgetSlicePresented = false
                        }
                    }
                }
            })
        })
        .onAppear(perform: controller.fetch)
    }

    init(budgetProvider: BudgetProvider) {
        self.controller = Controller(budgetProvider: budgetProvider)
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
