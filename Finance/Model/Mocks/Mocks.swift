//
//  Mocks.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import Foundation

#if DEBUG
enum Mocks {

    // MARK: - Budgets

    static let budgets: [Budget] = {
        [
            Budget(id: UUID(), name: "House", slices: Mocks.slices),
            Budget(id: UUID(), name: "Groceries", amount: .value(200.01)),
            Budget(id: UUID(), name: "Health", amount: .value(200.01))
        ]
    }()

    static let slices: [BudgetSlice] = {
        [
            BudgetSlice(id: .init(), name: "Mortgage", amount: .value(120.23)),
            BudgetSlice(id: .init(), name: "Furnitures", amount: .value(120.23))
        ]
    }()

    // MARK: - Transactions

    static let incomingTransactions: [Transaction] = {
        budgets
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(transfer: .income(amount: .value(100.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .income(amount: .value(200.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .income(amount: .value(300.02)), budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()

    static let outgoingTransactions: [Transaction] = {
        budgets
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(transfer: .expense(amount: .value(100.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .expense(amount: .value(200.02)), budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(transfer: .expense(amount: .value(300.02)), budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()
}
#endif
