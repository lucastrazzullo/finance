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

        let storageProvider: BudgetProvider

        init(storageProvider: BudgetProvider) {
            self.storageProvider = storageProvider
            self.budgets = []
        }

        func fetch() {
            storageProvider.fetchBudgets { [weak self] result in
                switch result {
                case .success(let budgets):
                    self?.budgets = budgets
                case .failure:
                    break
                }
            }
        }

        // MARK: Budget

        func save(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            storageProvider.save(budget: budget) { [weak self] result in
                self?.fetch()
                completion(result)
            }
        }

        func delete(budget: Budget, completion: @escaping (Result<Void, Error>) -> Void) {
            storageProvider.delete(budget: budget) { [weak self] result in
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

    init(storageProvider: BudgetProvider) {
        self.controller = Controller(storageProvider: storageProvider)
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static var previews: some View {
        let storageProvider = MockBudgetProvider()
        NavigationView {
            BudgetsView(storageProvider: storageProvider).navigationTitle("Budgets")
        }
    }
}

final class MockBudgetProvider: BudgetProvider {

    private var budgets: [Budget] = Mocks.budgets

    func save(budget: Budget, completion: ((Result<Void, Error>) -> Void)?) {
        budgets.append(budget)
        completion?(.success(Void()))
    }

    func delete(budget: Budget, completion: ((Result<Void, Error>) -> Void)?) {
        budgets.removeAll(where: { $0.id == budget.id })
        completion?(.success(Void()))
    }

    func fetchBudgets(completion: (Result<[Budget], Error>) -> Void) {
        completion(.success(budgets))
    }
}
