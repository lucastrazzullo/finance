//
//  YearlyBudgetOverview.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/02/2022.
//

import Foundation

struct YearlyBudgetOverview: Identifiable {

    static let defaultYear: Int = 2022
    static let defaultName: String = "Default"

    let id: UUID = .init()
    let name: String = Self.defaultName
    let year: Int = Self.defaultYear

    private(set) var budgets: [Budget]
    private(set) var transactions: [Transaction]

    // MARK: Object life cycle

    static var empty: Self {
        return try! Self.init(budgets: [], transactions: [])
    }

    init(budgets: [Budget], transactions: [Transaction]) throws {
        try Self.canUse(budgets: budgets, year: year)
        try Self.canUse(transactions: transactions, year: year)

        self.budgets = budgets
        self.transactions = transactions
    }

    // MARK: Monthly Overviews

    func monthlyOverviewsWithLowestAvailability(month: Int) -> [MonthlyBudgetOverview] {
        monthlyOverviews(month: month)
            .filter({ $0.remainingAmount <= .value(100) })
            .sorted(by: { $0.remainingAmount < $1.remainingAmount })
    }

    func monthlyOverviews(month: Int) -> [MonthlyBudgetOverview] {
        return budgets
            .map(\.id)
            .compactMap({ monthlyOverview(month: month, forBudgetWith: $0) })
    }

    func monthlyOverview(month: Int, forBudgetWith identifier: Budget.ID) -> MonthlyBudgetOverview? {
        guard let budget = budgets.first(where: { $0.id == identifier }) else {
            return nil
        }

        let transactionsForBudget = transactions
            .filter { transaction in return budget.slices.contains(where: { $0.id == transaction.budgetSliceId }) }

        let budgetAvailabilityUpToSelectedMonth = budget.availability(upTo: month)
        let totalAmountSpentUpToSelectedMonth = transactionsForBudget
            .filter { transaction in return transaction.month < month }
            .totalAmount

        let totalAmountSpentWithinSelectedMonth = transactionsForBudget
            .filter { transaction in return transaction.month == month }
            .totalAmount

        return MonthlyBudgetOverview(
            name: budget.name,
            icon: budget.icon,
            startingAmount: budgetAvailabilityUpToSelectedMonth - totalAmountSpentUpToSelectedMonth,
            totalExpenses: totalAmountSpentWithinSelectedMonth
        )
    }

    // MARK: Transactions

    mutating func set(transactions: [Transaction]) throws {
        try Self.canUse(transactions: transactions, year: year)
        self.transactions = transactions
    }

    mutating func append(transactions: [Transaction]) throws {
        try willAdd(transactions: transactions)
        self.transactions.append(contentsOf: transactions)
    }

    // MARK: Budgets

    mutating func set(budgets: [Budget]) throws {
        try Self.canUse(budgets: budgets, year: year)
        self.budgets = budgets
    }

    mutating func append(budget: Budget) throws {
        try willAdd(budget: budget)
        budgets.append(budget)
    }

    mutating func append(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        try willAdd(slice: slice, toBudgetWith: identifier)

        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].append(slice: slice)
        }
    }

    mutating func delete(budgetWithIdentifier identifier: Budget.ID) {
        budgets.delete(withIdentifier: identifier)
    }

    mutating func delete(budgetsWithIdentifiers identifiers: Set<Budget.ID>) {
        budgets.delete(withIdentifiers: identifiers)
    }

    mutating func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws {
        try willDelete(slicesWith: identifiers, inBudgetWith: identifier)

        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].delete(slicesWith: identifiers)
        }
    }

    mutating func update(name: String, icon: SystemIcon, forBudgetWith identifier: Budget.ID) throws {
        try willUpdate(name: name, forBudgetWith: identifier)

        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].update(name: name)
            try budgets[index].update(icon: icon)
        }
    }

    // MARK: Helper methods

    func willAdd(transactions: [Transaction]) throws {
        try Self.canUse(transactions: transactions, year: year)
    }

    func willAdd(budget: Budget) throws {
        try Self.canUse(budgets: [budget], year: year)
        try willIntroduce(newBudgetName: budget.name)
    }

    func willAdd(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) throws {
        try budgets.with(identifier: identifier)?.willAdd(slice: slice)
    }

    func willDelete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) throws {
        try budgets.with(identifier: identifier)?.willDelete(slicesWith: identifiers)
    }

    func willUpdate(name: String, forBudgetWith identifier: Budget.ID) throws {
        guard let budget = budgets.with(identifier: identifier), budget.name != name else {
            return
        }

        try budget.willUpdate(name: name)
        try willIntroduce(newBudgetName: name)
    }

    // MARK: Private helper methods

    private func willIntroduce(newBudgetName: String) throws {
        guard !budgets.contains(where: { $0.name == newBudgetName }) else {
            throw DomainError.budgetOverview(error: .budgetAlreadyExistsWith(name: newBudgetName))
        }
    }

    private static func canUse(budgets: [Budget], year: Int) throws {
        guard budgets.allSatisfy({ $0.year == year }) else {
            throw DomainError.budgetOverview(error: .budgetsListNotValid)
        }
    }

    private static func canUse(transactions: [Transaction], year: Int) throws {
        guard !transactions.contains(where: { $0.date.year != year }) else {
            throw DomainError.budgetOverview(error: .transactionsListNotValid)
        }
    }
}
