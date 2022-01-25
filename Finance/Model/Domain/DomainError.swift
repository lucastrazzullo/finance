//
//  DomainError.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

enum DomainError: Error {

    case budgets(error: BudgetsError)
    case budget(error: BudgetError)
    case budgetSlice(error: BudgetSliceError)
    case budgetProvider(error: BudgetStorageProviderError)

    case underlying(error: Error)

    static func with(error: Error) -> Self {
        return error as? DomainError ?? .underlying(error: error)
    }
}

enum BudgetsError {
    case budgetAlreadyExistsWith(name: String)
    case budgetDoesntExist
}

enum BudgetError {
    case sliceAlreadyExistsWith(name: String)
    case thereMustBeAtLeastOneSlice
    case nameNotValid
    case amountNotValid
}

enum BudgetSliceError {
    case nameNotValid
    case amountNotValid
}

enum BudgetStorageProviderError {
    case budgetEntityNotFound
    case underlying(error: Error)
}
