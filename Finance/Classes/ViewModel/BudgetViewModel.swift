//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetHandler: AnyObject {
    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws
    func update(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) async throws
}

@MainActor final class BudgetViewModel: ObservableObject {

    @Published var updatingBudgetName: String
    @Published var updatingBudgetIcon: SystemIcon
    @Published var updateBudgetInfoError: DomainError?

    @Published var isInsertNewSlicePresented: Bool = false
    @Published var deleteSlicesError: DomainError?

    var name: String {
        return budget.name
    }

    var amount: MoneyValue {
        return budget.amount
    }

    var slices: [BudgetSlice] {
        return budget.slices
    }

    var systemIconName: String {
        return budget.icon.rawValue
    }

    private let budget: Budget
    private weak var handler: BudgetHandler?

    // MARK: Object life cycle

    init(budget: Budget, handler: BudgetHandler?) {
        self.handler = handler
        self.budget = budget
        self.updatingBudgetName = budget.name
        self.updatingBudgetIcon = budget.icon
    }

    // MARK: Internal methods

    func add(slice: BudgetSlice) async throws {
        try BudgetValidator.willAdd(slice: slice, to: budget.slices)
        try await handler?.add(slice: slice, toBudgetWith: budget.id)
        isInsertNewSlicePresented = false
    }

    func delete(slicesAt offsets: IndexSet) async {
        do {
            let identifiers = budget.slices(at: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try BudgetValidator.willDelete(slicesWith: identifiersSet, from: budget.slices)
            try await handler?.delete(slicesWith: identifiersSet, inBudgetWith: budget.id)
            deleteSlicesError = nil
        } catch {
            deleteSlicesError = error as? DomainError
        }
    }

    func saveUpdates() async {
        do {
            try BudgetValidator.canUse(name: name)
            try await handler?.update(name: updatingBudgetName, icon: updatingBudgetIcon, inBudgetWith: budget.id)
            updateBudgetInfoError = nil
        } catch {
            updateBudgetInfoError = error as? DomainError
        }
    }
}
