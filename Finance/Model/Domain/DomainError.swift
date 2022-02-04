//
//  DomainError.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

protocol DomainUnderlyingError {
    var description: String { get }
}

enum DomainError: Error, Identifiable {

    case budgets(error: BudgetsError)
    case budget(error: BudgetError)
    case budgetSlice(error: BudgetSliceError)
    case budgetProvider(error: BudgetStorageProviderError)

    case underlying(error: Error)

    static func with(error: Error) -> Self {
        return error as? DomainError ?? .underlying(error: error)
    }

    var id: String {
        switch self {
        case .budgets:
            return "budgets"
        case .budget:
            return "budget"
        case .budgetSlice:
            return "budgetSlice"
        case .budgetProvider:
            return "budgetProvider"
        case .underlying:
            return "underlying"
        }
    }

    var description: String {
        switch self {
        case .budgets(let error):
            return error.description
        case .budget(let error):
            return error.description
        case .budgetSlice(let error):
            return error.description
        case .budgetProvider(let error):
            return error.description
        case .underlying(_):
            return "Something went wrong!"
        }
    }
}

enum BudgetsError: DomainUnderlyingError {
    case budgetAlreadyExistsWith(name: String)
    case budgetDoesntExist

    var description: String {
        switch self {
        case .budgetAlreadyExistsWith(let name):
            return "A budget named: \(name) already exists."
        case .budgetDoesntExist:
            return "The budget you are looking for doesn't exist"
        }
    }
}

enum BudgetError: DomainUnderlyingError {

    enum SlicesErrorReason {
        case sliceAlreadyExistsWith(name: String)
        case sliceDoesntExist
        case thereMustBeAtLeastOneSlice
    }

    case nameNotValid
    case amountNotValid
    case slicesNotValid(reason: SlicesErrorReason)
    case cannotUpdateTheBudget(underlyingError: Error)
    case cannotCreateTheBudget(underlyingError: Error)

    var description: String {
        switch self {
        case .nameNotValid:
            return "Please use a valid name"
        case .amountNotValid:
            return "Please use a valid amount"
        case .slicesNotValid(let reason):
            switch reason {
            case .sliceAlreadyExistsWith(let name):
                return "A slice named: \(name) already exists."
            case .sliceDoesntExist:
                return "The slice you're trying to modify or delete doesn't exist"
            case .thereMustBeAtLeastOneSlice:
                return "There must be at least one slice."
            }
        case .cannotUpdateTheBudget:
            return "This budget cannot be updated!"
        case .cannotCreateTheBudget:
            return "This budget cannot be created!"
        }
    }
}

enum BudgetSliceError: DomainUnderlyingError {
    case nameNotValid
    case amountNotValid
    case cannotCreateTheSlice(underlyingError: Error)

    var description: String {
        switch self {
        case .nameNotValid:
            return "Please use a valid name"
        case .amountNotValid:
            return "Please use a valid amount"
        case .cannotCreateTheSlice:
            return "This slice cannot be created!"
        }
    }
}

enum BudgetStorageProviderError: DomainUnderlyingError {
    case budgetEntityNotFound
    case cannotCreateBudgetWithEntity
    case underlying(error: Error)

    var description: String {
        switch self {
        case .budgetEntityNotFound:
            return "The budget you're looking for is missing"
        case .cannotCreateBudgetWithEntity:
            return "Cannot generate budget with entity"
        case .underlying(_):
            return "Something went wrong!"
        }
    }
}
