//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetStorageHandler: AnyObject {
    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws
    func update(name: String, icon: SystemIcon, in budget: Budget) async throws
}

@MainActor final class BudgetViewModel: ObservableObject {

    @Published var budget: Budget

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

    private let storageHandler: BudgetStorageHandler

    // MARK: Object life cycle

    init(budget: Budget, storageHandler: BudgetStorageHandler) {
        self.budget = budget
        self.storageHandler = storageHandler

        self.updatingBudgetName = budget.name
        self.updatingBudgetIcon = budget.icon
    }

    // MARK: Internal methods

    func add(slice: BudgetSlice) async throws {
        try BudgetValidator.willAdd(slice: slice, to: budget.slices)
        try await storageHandler.add(slice: slice, toBudgetWith: budget.id)
        try budget.append(slice: slice)
        isInsertNewSlicePresented = false
    }

    func delete(slicesAt offsets: IndexSet) async {
        do {
            let identifiers = budget.slices(at: offsets).map(\.id)
            let identifiersSet = Set(identifiers)

            try BudgetValidator.willDelete(slicesWith: identifiersSet, from: budget.slices)
            try await storageHandler.delete(slicesWith: identifiersSet, inBudgetWith: budget.id)
            try budget.delete(slicesWith: identifiersSet)
            deleteSlicesError = nil
        } catch {
            deleteSlicesError = error as? DomainError
        }
    }

    func saveUpdates() async {
        do {
            try BudgetValidator.canUse(name: updatingBudgetName)
            try await storageHandler.update(name: updatingBudgetName, icon: updatingBudgetIcon, in: budget)
            try budget.update(name: updatingBudgetName)
            try budget.update(icon: updatingBudgetIcon)
            updateBudgetInfoError = nil
        } catch {
            updateBudgetInfoError = error as? DomainError
        }
    }
}
