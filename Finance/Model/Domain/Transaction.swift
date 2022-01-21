//
//  Transaction.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct Transaction: Identifiable, TransferHolder {

    let id: UUID = UUID()
    let date: Date = Date()
    let transfer: Transfer
    let description: String?
    let budgetId: Budget.ID
    let budgetSliceId: BudgetSlice.ID

    init(transfer: Transfer, description: String? = nil, budgetId: Budget.ID, budgetSliceId: BudgetSlice.ID) {
        self.transfer = transfer
        self.description = description
        self.budgetId = budgetId
        self.budgetSliceId = budgetSliceId
    }
}
