//
//  DomainError.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import Foundation

protocol DomainUnderlyingError {
    var id: String { get }
    var description: String { get }
    var accessibilityIdentifier: String { get }
}

enum DomainError: Error, Identifiable {

    case report(error: ReportError)
    case budget(error: BudgetError)
    case budgetSlice(error: BudgetSliceError)
    case storageProvider(error: StorageProviderError)
    case underlying(error: AnyUnderlyingError)

    static func with(error: Error) -> Self {
        return error as? DomainError ?? .underlying(error: .swiftError(error: error))
    }

    var id: String {
        underlyingError.id
    }

    var description: String {
        underlyingError.description
    }

    var accessibilityIdentifier: String {
        underlyingError.accessibilityIdentifier
    }

    var underlyingError: DomainUnderlyingError {
        switch self {
        case .report(let error):
            return error
        case .budget(let error):
            return error
        case .budgetSlice(let error):
            return error
        case .storageProvider(let error):
            return error
        case .underlying(let error):
            return error
        }
    }

    var localizedDescription: String {
        return description
    }
}

enum ReportError: DomainUnderlyingError {

    case reportIsNotLoaded
    case nameNotValid
    case budgetAlreadyExistsWith(name: String)
    case budgetDoesntExist
    case cannotFetchTheBudgets

    var id: String {
        return "Report"
    }

    var description: String {
        switch self {
        case .reportIsNotLoaded:
            return "Report is not loaded"
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

    var accessibilityIdentifier: String {
        switch self {
        case .nameNotValid:
            return AccessibilityIdentifier.Error.invalidNameError
        case .budgetAlreadyExistsWith:
            return AccessibilityIdentifier.Error.sameNameError
        default:
            return AccessibilityIdentifier.Error.someError
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

    var id: String {
        return "Budget"
    }

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

    var accessibilityIdentifier: String {
        switch self {
        case .nameNotValid:
            return AccessibilityIdentifier.Error.invalidNameError
        case .amountNotValid:
            return AccessibilityIdentifier.Error.invalidAmountError
        case .multipleSlicesWithSameName:
            return AccessibilityIdentifier.Error.sameNameError
        case .sliceAlreadyExistsWith:
            return AccessibilityIdentifier.Error.sameNameError
        default:
            return AccessibilityIdentifier.Error.someError
        }
    }
}

enum BudgetSliceError: DomainUnderlyingError {

    case nameNotValid
    case amountNotValid
    case scheduleMonthNotValid
    case scheduleAlreadyExistsFor(month: String)
    case scheduleDoesntExistFor(month: String)
    case thereMustBeAtLeastOneSchedule
    case cannotAddSchedule(underlyingError: Error?)
    case cannotCreateTheSlice(underlyingError: Error?)

    var id: String {
        return "Budget slice"
    }

    var description: String {
        switch self {
        case .nameNotValid:
            return "Please use a valid name"
        case .amountNotValid:
            return "Please use a valid amount"
        case .scheduleMonthNotValid:
            return "Month not valid"
        case .scheduleAlreadyExistsFor(let month):
            return "Schedule already exists for \(month)"
        case .scheduleDoesntExistFor(let month):
            return "Schedule not found for \(month)"
        case .thereMustBeAtLeastOneSchedule:
            return "There must be at least one schedule"
        case .cannotAddSchedule:
            return "Cannot add schedule"
        case .cannotCreateTheSlice:
            return "This slice cannot be created!"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .nameNotValid:
            return AccessibilityIdentifier.Error.invalidNameError
        case .amountNotValid:
            return AccessibilityIdentifier.Error.invalidAmountError
        default:
            return AccessibilityIdentifier.Error.someError
        }
    }
}

enum StorageProviderError: DomainUnderlyingError {
    case budgetEntityNotFound
    case cannotCreateBudgetWithEntity
    case underlying(error: Error)

    var id: String {
        return "Storage provider"
    }

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

    var accessibilityIdentifier: String {
        switch self {
        default:
            return AccessibilityIdentifier.Error.someError
        }
    }
}

enum AnyUnderlyingError: DomainUnderlyingError {
    case swiftError(error: Error)

    var id: String {
        return "Any underlying error"
    }

    var description: String {
        return "Something went wrong!"
    }

    var accessibilityIdentifier: String {
        return AccessibilityIdentifier.Error.someError
    }
}
