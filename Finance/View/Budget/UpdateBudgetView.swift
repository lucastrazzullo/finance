//
//  UpdateBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/01/2022.
//

import SwiftUI

struct UpdateBudgetView: View {

    typealias OnSubmitErrorHandler = (DomainError?) -> Void

    let onSubmit: (Budget, @escaping OnSubmitErrorHandler) -> Void

    private let budgetId: Budget.ID

    @State private var budgetName: String
    @State private var budgetSlices: [BudgetSlice]

    @State private var presentedError: DomainError?
    @State private var isInsertNewBudgetSlicePresented: Bool = false

    var body: some View {
        VStack {
            AmountCollectionItem(title: "Monthly total",
                                 caption: nil,
                                 amount: budgetSlices.totalAmount,
                                 color: .gray.opacity(0.4))
                .padding()

            Form {
                Section(header: Text("Budget Name")) {
                    TextField("Name", text: $budgetName)

                    if let error = presentedError, case .budget(let inlineError) = error, case .nameNotValid = inlineError {
                        Color.red.frame(height: 2)
                    }
                }

                Section(header: Text("Slices")) {
                    List {
                        ForEach(budgetSlices) { slice in
                            AmountListItem(label: slice.name, amount: slice.amount)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        do {
                                            try Budget.canRemove(slice: slice, from: budgetSlices)
                                            budgetSlices.removeAll(where: { $0.id == slice.id })
                                        } catch {
                                            presentedError = error as? DomainError ?? .budget(error: .cannotUpdateTheBudget(underlyingError: error))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }

                    if let error = presentedError, case .budget(let inlineError) = error, case .slicesNotValid = inlineError {
                        Color.red.frame(height: 2)
                    }

                    Button(action: { isInsertNewBudgetSlicePresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }

                Section {
                    if let error = presentedError {
                        InlineErrorView(error: error)
                    }

                    Button("Save") {
                        do {
                            onSubmit(try Budget(id: budgetId, name: budgetName, slices: budgetSlices)) { error in
                                presentedError = error
                            }
                        } catch {
                            presentedError = error as? DomainError ?? .budget(error: .cannotUpdateTheBudget(underlyingError: error))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isInsertNewBudgetSlicePresented) {
            NewBudgetSliceView { slice, onErrorHandler in
                do {
                    try Budget.canAdd(newSlice: slice, to: budgetSlices)
                    budgetSlices.append(slice)
                    isInsertNewBudgetSlicePresented = false
                } catch {
                    onErrorHandler(error as? DomainError ?? .underlying(error: error))
                }
            }
        }
    }

    init(budget: Budget, onSubmit: @escaping (Budget, @escaping OnSubmitErrorHandler) -> Void) {
        self.onSubmit = onSubmit
        self.budgetId = budget.id
        self._budgetName = State<String>(wrappedValue: budget.name)
        self._budgetSlices = State<[BudgetSlice]>(wrappedValue: budget.slices)
    }
}

// MARK: - Previews

struct UpdateBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateBudgetView(budget: Mocks.budgets[0]) { _, _ in }
    }
}
