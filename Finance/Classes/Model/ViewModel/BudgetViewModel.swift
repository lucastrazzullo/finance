//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import Foundation

struct BudgetViewModel {

    enum SystemIcon: String, CaseIterable {
        case face = "face.dashed.fill"
        case face2 = "face.smiling.fill"
        case food = "fork.knife"
        case car = "bolt.car"
        case health = "leaf"
        case travel = "airplane"
        case `default` = "creditcard.and.123"
    }

    // MARK: Private properteis

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
        switch budget.icon {
        case .system(let name):
            return name
        case .none:
            return SystemIcon.default.rawValue
        }
    }
}
