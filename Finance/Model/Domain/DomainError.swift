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

    case report(error: ReportError)
    case budget(error: BudgetError)
    case budgetSlice(error: BudgetSliceError)
    case budgetProvider(error: BudgetStorageProviderError)

    case underlying(error: Error)

    static func with(error: Error) -> Self {
        return error as? DomainError ?? .underlying(error: error)
    }

    var id: String {
        switch self {
        case .report:
            return "Report"
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
        case .report(let error):
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

    var localizedDescription: String {
        return description
    }
}

enum ReportError: DomainUnderlyingError {

    case nameNotValid
    case budgetAlreadyExistsWith(name: String)
    case budgetDoesntExist
    case cannotFetchTheBudgets

    var description: String {
        switch self {
        case .nameNotValid:
            return "Name not valid!"
        case .budgetAlreadyExistsWith(let name):
            return "A budget named: \(name) already exists"
        case .budgetDoesntExist:
            return "The budget you are looking for doesn't exist"
        case .cannotFetchTheBudgets:
            return "Budgets cannot be fetched right now"
        }
    }
}

enum BudgetError: DomainUnderlyingError {

    case nameNotValid
    case amountNotValid
    case multipleSlicesWithSameName
    case sliceAlreadyExistsWith(name: String)
    case thereMustBeAtLeastOneSlice
    case sliceDoesntExistWith(name: String)
    case cannotAddSlice(underlyingError: Error?)
    case cannotDeleteSlice(underlyingError: Error?)
    case cannotFetchTheBudget(id: Budget.ID)
    case cannotUpdateTheBudget(underlyingError: Error?)
    case cannotCreateTheBudget(underlyingError: Error?)

    var description: String {
        switch self {
        case .nameNotValid:
            return "Please use a valid name"
        case .amountNotValid:
            return "Please use a valid amount"
        case .multipleSlicesWithSameName:
            return "The budget cannot have slices with the same name"
        case .sliceAlreadyExistsWith(let name):
            return "A slice named \(name) already exists!"
        case .sliceDoesntExistWith(let name):
            return "A slice named \(name) doesn't exist"
        case .thereMustBeAtLeastOneSlice:
            return "There must be at least one slice."
        case .cannotAddSlice:
            return "Cannot add the slice"
        case .cannotDeleteSlice:
            return "Cannot delete the slice"
        case .cannotFetchTheBudget(let id):
            return "The budget with id: \(id) cannot be fetched!"
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
    case cannotCreateTheSlice(underlyingError: Error?)

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
