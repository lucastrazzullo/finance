//
//  YearlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct YearlyBudgetOverview: Identifiable {

    let id: UUID
    let name: String
    let year: Int

    private(set) var budgets: [Budget]
    private(set) var transactions: [Transaction]

    // MARK: Object life cycle

    init(id: ID = .init(), name: String, year: Int, budgets: [Budget], transactions: [Transaction]) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetOverview(error: .nameNotValid)
        }
        guard budgets.allSatisfy({ $0.year == year }) else {
            throw DomainError.budgetOverview(error: .budgetsListNotValid)
        }

        let allBudgetSlicesIdentifiers = budgets.flatMap({ $0.slices }).map(\.id)
        guard transactions.allSatisfy({ $0.year == year && allBudgetSlicesIdentifiers.contains($0.budgetSliceId) }) else {
            throw DomainError.budgetOverview(error: .transactionsListNotValid)
        }

        self.id = id
        self.name = name
        self.year = year
        self.budgets = budgets
        self.transactions = transactions
    }

    // MARK: Overview

    func monthlyOverviews(month: Int) -> [MonthlyBudgetOverview] {
        return budgets
            .map(\.id)
            .compactMap({ monthlyOverview(month: month, forBudgetWith: $0) })
    }

    func monthlyOverview(month: Int, forBudgetWith identifier: Budget.ID) -> MonthlyBudgetOverview? {
        guard let budget = budget(with: identifier) else {
            return nil
        }

        let budgetAvailabilityUpToSelectedMonth = budget.availability(upTo: month)
        let totalAmountSpentUpToSelectedMonth = transactions
            .filter { transaction in return transaction.month < month }
            .totalAmount

        let totalAmountSpentWithinSelectedMonth = transactions
            .filter { transaction in return transaction.month == month }
            .totalAmount

        return MonthlyBudgetOverview(
            name: budget.name,
            icon: budget.icon,
            startingAmount: budgetAvailabilityUpToSelectedMonth - totalAmountSpentUpToSelectedMonth,
            totalExpenses: totalAmountSpentWithinSelectedMonth
        )
    }

    // MARK: Budget

    func budget(with identifier: Budget.ID) -> Budget? {
        return budgets.first(where: { $0.id == identifier })
    }

    func budget(at index: Int) -> Budget? {
        guard budgets.indices.contains(index) else {
            return nil
        }
        return budgets[index]
    }

    func budgets(at indices: IndexSet) -> [Budget] {
        return budgets
            .enumerated()
            .filter { index, budget -> Bool in indices.contains(index) }
            .map(\.element)
    }

    func budgets(with identifiers: Set<Budget.ID>) -> [Budget] {
        return budgets.filter({ identifiers.contains($0.id) })
    }

    func budgetIdentifiers(at indices: IndexSet) -> Set<Budget.ID> {
        return Set(budgets(at: indices).map(\.id))
    }

    func budgetIdentifiers() -> Set<Budget.ID> {
        return Set(budgets.map(\.id))
    }

    // MARK: - Mutating methods

    mutating func delete(budgetWith id: Budget.ID) {
        budgets.removeAll(where: { $0.id == id })
    }

    mutating func delete(budgetsWith identifiers: Set<Budget.ID>) {
        budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    mutating func append(budget: Budget) throws {
        try willAdd(budget: budget)
        budgets.append(budget)
    }

    mutating func append(transaction: Transaction) {
        self.transactions.append(transaction)
    }

    // MARK: Helper methods

    func willAdd(budget: Budget) throws {
        try willIntroduce(newBudgetName: budget.name)
    }

    func willUpdate(budgetName: String, forBudgetWith id: Budget.ID) throws {
        guard budgets.contains(where: { $0.id == id && $0.name != budgetName }) else {
            return
        }
        try willIntroduce(newBudgetName: budgetName)
    }

    private func willIntroduce(newBudgetName: String) throws {
        guard !budgets.contains(where: { $0.name == newBudgetName }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: newBudgetName))
        }
    }
}
