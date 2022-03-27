//
//  BudgetController.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

final class BudgetController: ObservableObject {

    @Published private(set) var budget: Budget

    private let repository: Repository

    init(budget: Budget, storageProvider: StorageProvider) {
        self.budget = budget
        self.repository = Repository(storageProvider: storageProvider)
    }

    // MARK: Public methods

    func fetch() async throws {
        let budget = try await repository.fetch(budgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            self?.budget = budget
        }
    }

    func add(slice: BudgetSlice) async throws {
        try budget.willAdd(slice: slice)
        try await repository.add(slice: slice, toBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.append(slice: slice)
        }
    }

    func delete(slicesAt indices: IndexSet) async throws {
        let identifiers = budget.sliceIdentifiers(at: indices)
        try budget.willDelete(slicesWith: identifiers)
        try await repository.delete(slicesWith: identifiers, inBudgetWith: budget.id)

        DispatchQueue.main.async { [weak self] in
            try? self?.budget.delete(slicesAt: indices)
        }
    }
}
