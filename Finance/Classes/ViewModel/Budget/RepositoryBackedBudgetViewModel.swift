//
//  RepositoryBackedBudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class RepositoryBackedBudgetViewModel: ObservableObject {

    @Published private(set) var budget: Budget

    private let repository: Repository

    // MARK: Object life cycle

    init(budget: Budget, repository: Repository) {
        self.budget = budget
        self.repository = repository
    }
}

extension RepositoryBackedBudgetViewModel: BudgetViewModel {

    var name: String {
        return budget.name
    }

    var icon: Icon {
        return budget.icon
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

    func update(budgetName name: String, systemIcon: SystemIcon) async throws {
        let icon = Icon.system(icon: systemIcon)

        guard name != budget.name || icon != budget.icon else {
            return
        }

        try await repository.update(name: name, iconSystemName: systemIcon.rawValue, inBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.update(icon: icon)
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
