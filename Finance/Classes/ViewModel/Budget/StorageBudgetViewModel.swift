//
//  StorageBudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class StorageBudgetViewModel: ObservableObject {

    @Published private(set) var budget: Budget

    private let repository: Repository

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.budget = budget
        self.repository = Repository(storageProvider: storageProvider)
    }
}

extension StorageBudgetViewModel: BudgetViewModel {

    var name: String {
        return budget.name
    }

    var iconSystemName: String {
        switch budget.icon {
        case .system(let name):
            return name
        case .none:
            return SystemIcon.default.rawValue
        }
    }

    var amount: MoneyValue {
        return budget.amount
    }

    var slices: [BudgetSlice] {
        return budget.slices
    }

    func fetch() async throws {
        let budget = try await repository.fetch(budgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            self?.budget = budget
        }
    }

    func update(budgetName name: String, iconSystemName: String) async throws {
        guard name != budget.name || Budget.Icon.system(name: iconSystemName) != budget.icon else {
            return
        }

        try await repository.update(name: name, iconSystemName: iconSystemName, inBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.update(iconSystemName: iconSystemName)
            try? self?.budget.update(name: name)
        }
    }

    func add(slice: BudgetSlice) async throws {
        try await repository.add(slice: slice, toBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.append(slice: slice)
        }
    }

    func delete(slicesAt indices: IndexSet) async throws {
        let identifiers = budget.sliceIdentifiers(at: indices)
        try await repository.delete(slicesWith: identifiers, inBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.delete(slicesAt: indices)
        }
    }
}