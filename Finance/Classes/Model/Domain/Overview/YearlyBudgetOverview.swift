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

    // MARK: - Mutating methods

    mutating func append(budget: Budget) {
        self.budgets.append(budget)
    }

    mutating func delete(budgetsWithIdentifiers identifiers: Set<Budget.ID>) {
        self.budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    mutating func append(transactions: [Transaction]) {
        self.transactions.append(contentsOf: transactions)
    }
}
