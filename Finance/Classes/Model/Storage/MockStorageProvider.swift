//
//  MockStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/01/2022.
//

import Foundation

enum Mocks {

    // MARK: - Year

    static let year: Int = 2022

    // MARK: - Budget

    static func randomBudgetIdentifiers(count: Int) -> [Budget.ID] {
        let favouriteBudgetsIdentifiers: Set<Budget.ID> = Set(favouriteBudgetsIdentifiers)
        var budgets = budgets.map(\.id).shuffled()
        budgets.removeAll(where: { favouriteBudgetsIdentifiers.contains($0) })
        guard budgets.count > count else {
            return budgets
        }
        return Array(budgets[0..<count])
    }

    static let favouriteBudgetsIdentifiers: [Budget.ID] = {
        return [
            budgets.first(where: { $0.name == "Ilenia" })?.id,
            budgets.first(where: { $0.name == "Groceries" })?.id,
            budgets.first(where: { $0.name == "Car" })?.id,
            budgets.first(where: { $0.name == "Health" })?.id
        ].compactMap({$0})
    }()

    static let budgets: [Budget] = {
        return [
            try! .init(id: UUID(), year: year, name: "House", icon: .house, slices: Mocks.houseSlices),
            try! .init(id: UUID(), year: year, name: "Groceries", icon: .food, slices: Mocks.groceriesSlices),
            try! .init(id: UUID(), year: year, name: "Health", icon: .health, monthlyAmount: .value(200.01)),
            try! .init(id: UUID(), year: year, name: "Luca", icon: .face2, monthlyAmount: .value(250.01)),
            try! .init(id: UUID(), year: year, name: "Travel", icon: .travel, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Ilenia", icon: .face, monthlyAmount: .value(1000.00)),
            try! .init(id: UUID(), year: year, name: "Car", icon: .car, monthlyAmount: .value(1000.00)),
        ]
    }()

    // MARK: Slice

    static let allSlices: [BudgetSlice] = {
        groceriesSlices + houseSlices
    }()

    static let houseSlices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Mortgage", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Furnitures", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Works", configuration: .scheduled(schedules: sliceScheduledAmounts))
        ]
    }()

    static let groceriesSlices: [BudgetSlice] = {
        [
            try! .init(id: .init(), name: "Food", configuration: .monthly(amount: .value(120.23))),
            try! .init(id: .init(), name: "Home", configuration: .monthly(amount: .value(120.23))),
        ]
    }()

    static let sliceScheduledAmounts: [BudgetSlice.Schedule] = {
        [
            try! .init(amount: .value(100), month: 1),
            try! .init(amount: .value(200), month: 2),
            try! .init(amount: .value(300), month: 7)
        ]
    }()

    static let transactions: [Transaction] = {
        var components = DateComponents()
        components.year = year
        let date = Calendar.current.date(from: components)!
        return [
            Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[0].id),
            Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[1].id),
            Transaction(id: .init(), description: nil, amount: .value(100), date: date, budgetSliceId: houseSlices[2].id),
            Transaction(id: .init(), description: nil, amount: .value(1000), date: date, budgetSliceId: groceriesSlices[0].id),
            Transaction(id: .init(), description: nil, amount: .value(1000), date: date, budgetSliceId: groceriesSlices[1].id)
        ]
    }()
}

final class MockStorageProvider: StorageProvider {

    private enum Error: Swift.Error {
        case mock
    }

    private var transactions: [Transaction]
    private var budgets: [Budget]

    // MARK: Object life cycle

    init() {
        self.transactions = []
        self.budgets = []
    }

    init(budgets: [Budget], transactions: [Transaction]) {
        self.transactions = transactions
        self.budgets = budgets
    }

    // MARK: Fetch

    func fetchBudgets(year: Int) async throws -> [Budget] {
        return budgets.filter { budget in
            budget.year == year
        }
    }

    func fetchTransactions(year: Int) async throws -> [Transaction] {
        return transactions.filter { transaction in
            transaction.date.year == year
        }
    }

    // MARK: Add

    func add(transaction: Transaction) async throws {
        self.transactions.append(transaction)
    }

    func add(budget: Budget) async throws {
        self.budgets.append(budget)
    }

    func add(slice: BudgetSlice, toBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].append(slice: slice)
        }
    }

    // MARK: Delete

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        transactions.removeAll(where: { identifiers.contains($0.id) })
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        budgets.removeAll(where: { identifiers.contains($0.id) })
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].delete(slicesWith: identifiers)
        }
    }

    // MARK: Update

    func update(name: String, iconSystemName: String, inBudgetWith identifier: Budget.ID) async throws {
        if let index = budgets.firstIndex(where: { $0.id == identifier }) {
            try budgets[index].update(name: name)
            try budgets[index].update(icon: SystemIcon(rawValue: iconSystemName)!)
        }
    }
}
