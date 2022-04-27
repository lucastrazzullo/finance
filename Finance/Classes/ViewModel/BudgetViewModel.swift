//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 19/04/2022.
//

import Foundation

protocol BudgetDataProvider: AnyObject {
    func budget(with identifier: Budget.ID) async throws -> Budget
    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws
    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws
    func update(name: String, icon: SystemIcon, in budget: Budget) async throws
}

@MainActor final class BudgetViewModel: ObservableObject {

    @Published var updatingBudgetName: String
    @Published var updatingBudgetIcon: SystemIcon
    @Published var updateBudgetInfoError: DomainError?

    @Published var isInsertNewSlicePresented: Bool = false
    @Published var deleteSlicesError: DomainError?

    @Published var budget: Budget

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

    private let dataProvider: BudgetDataProvider

    // MARK: Object life cycle

    init(budget: Budget, dataProvider: BudgetDataProvider) {
        self.budget = budget
        self.dataProvider = dataProvider

        self.updatingBudgetName = budget.name
        self.updatingBudgetIcon = budget.icon
    }

    // MARK: Internal methods

    func add(slice: BudgetSlice) async throws {
        try BudgetValidator.willAdd(slice: slice, to: budget.slices)
        try await dataProvider.add(slice: slice, toBudgetWith: budget.id)

        budget = try await dataProvider.budget(with: budget.id)
        isInsertNewSlicePresented = false
    }

    func delete(slicesAt offsets: IndexSet) async {
        do {
            let identifiers = budget.slices(at: offsets).map(\.id)
            let identifiersSet = Set(identifiers)

            try BudgetValidator.willDelete(slicesWith: identifiersSet, from: budget.slices)
            try await dataProvider.delete(slicesWith: identifiersSet, inBudgetWith: budget.id)

            budget = try await dataProvider.budget(with: budget.id)
            deleteSlicesError = nil
        } catch {
            deleteSlicesError = error as? DomainError
        }
    }

    func saveUpdates() async {
        do {
            try BudgetValidator.canUse(name: name)
            try await dataProvider.update(name: updatingBudgetName, icon: updatingBudgetIcon, in: budget)

            budget = try await dataProvider.budget(with: budget.id)
            updateBudgetInfoError = nil
        } catch {
            updateBudgetInfoError = error as? DomainError
        }
    }
}
