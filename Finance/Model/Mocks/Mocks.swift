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

    static let budgets: Budgets = {
        Budgets(list: [
            try! Budget(id: UUID(), name: "House", slices: Mocks.slices),
            try! Budget(id: UUID(), name: "Groceries", amount: .value(200.01)),
            try! Budget(id: UUID(), name: "Health", amount: .value(200.01))
        ])
    }()

    static let slices: BudgetSlices = {
        try! BudgetSlices(list: [
            try! BudgetSlice(id: .init(), name: "Mortgage", amount: .value(120.23)),
            try! BudgetSlice(id: .init(), name: "Furnitures", amount: .value(120.23))
        ])
    }()

    // MARK: - Transactions

    static let incomingTransactions: [Transaction] = {
        budgets.all()
            .map { budget in
                budget.slices.all().map { slice in
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
        budgets.all()
            .map { budget in
                budget.slices.all().map { slice in
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
