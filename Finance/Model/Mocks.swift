//
//  Mocks.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import Foundation

#if DEBUG
enum Mocks {

    // MARK: - Transactions

    static let incomingTransactions: [Transaction] = {
        BudgetProvider.incomingBudgetList
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(amount: .value(100.02), type: .income, budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(amount: .value(200.02), type: .income, budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(amount: .value(300.02), type: .income, budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()

    static let outgoingTransactions: [Transaction] = {
        BudgetProvider.expensesBudgetList
            .map { budget in
                budget.slices.map { slice in
                    [
                        Transaction(amount: .value(100.02), type: .expense, budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(amount: .value(200.02), type: .expense, budgetId: budget.id, budgetSliceId: slice.id),
                        Transaction(amount: .value(300.02), type: .expense, budgetId: budget.id, budgetSliceId: slice.id)
                    ]
                }
                .flatMap({$0})
            }
            .flatMap({$0})
    }()
}
#endif
