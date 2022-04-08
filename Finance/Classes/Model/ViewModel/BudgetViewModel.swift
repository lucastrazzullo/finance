//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import Foundation

struct BudgetViewModel {

    private let budget: Budget

    init(budget: Budget) {
        self.budget = budget
    }

    // MARK: Computed properties

    var name: String {
        return budget.name
    }

    var amount: MoneyValue {
        return budget.amount
    }

    var iconSystemName: String {
        if case .system(let name) = budget.icon {
            return name
        } else {
            return "creditcard.and.123"
        }
    }
}
