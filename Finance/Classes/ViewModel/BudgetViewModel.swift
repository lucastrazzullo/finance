//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetViewModelDelegate: AnyObject {
    func didAdd(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws
    func didDelete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws

    func willUpdate(name: String, in budget: Budget) throws
    func didUpdate(name: String, icon: SystemIcon, inBudgetWith identifier: Budget.ID) throws
}

@MainActor final class BudgetViewModel: ObservableObject {

    @Published var updatingBudgetName: String
    @Published var updatingBudgetIcon: SystemIcon
    @Published var updateBudgetInfoError: DomainError?

    @Published var isInsertNewSlicePresented: Bool = false
    @Published var deleteSlicesError: DomainError?

    @Published var budget: Budget

    weak var delegate: BudgetViewModelDelegate?

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

    private let storageProvider: StorageProvider

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider, delegate: BudgetViewModelDelegate?) {
        self.budget = budget
        self.storageProvider = storageProvider
        self.delegate = delegate

        self.updatingBudgetName = budget.name
        self.updatingBudgetIcon = budget.icon
    }

    // MARK: Internal methods

    func add(slice: BudgetSlice) async throws {
        try BudgetValidator.willAdd(slice: slice, to: budget.slices)
        try await storageProvider.add(slice: slice, toBudgetWith: budget.id)
        
        try budget.append(slice: slice)
        try delegate?.didAdd(slice: slice, toBudgetWith: budget.id)

        isInsertNewSlicePresented = false
    }

    func delete(slicesAt offsets: IndexSet) async {
        do {
            let identifiers = budget.slices(at: offsets).map(\.id)
            let identifiersSet = Set(identifiers)

            try BudgetValidator.willDelete(slicesWith: identifiersSet, from: budget.slices)
            try await storageProvider.delete(slicesWith: identifiersSet, inBudgetWith: budget.id)

            try budget.delete(slicesWith: identifiersSet)
            try delegate?.didDelete(slicesWith: identifiersSet, inBudgetWith: budget.id)

            deleteSlicesError = nil
        } catch {
            deleteSlicesError = error as? DomainError
        }
    }

    func saveUpdates() async {
        do {
            try BudgetValidator.canUse(name: name)
            try delegate?.willUpdate(name: updatingBudgetName, in: budget)

            try await storageProvider.update(name: updatingBudgetName, iconSystemName: updatingBudgetIcon.rawValue, inBudgetWith: budget.id)

            try budget.update(name: updatingBudgetName)
            try budget.update(icon: updatingBudgetIcon)
            try delegate?.didUpdate(name: budget.name, icon: budget.icon, inBudgetWith: budget.id)

            updateBudgetInfoError = nil

        } catch {
            updateBudgetInfoError = error as? DomainError
        }
    }
}
