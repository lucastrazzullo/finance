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

    case budgetOverview(error: BudgetOverviewError)
    case budget(error: BudgetError)
    case budgetSlice(error: BudgetSliceError)
    case transaction(error: TransactionError)
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
        case .budgetOverview(let error):
            return error
        case .budget(let error):
            return error
        case .budgetSlice(let error):
            return error
        case .transaction(let error):
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

enum BudgetOverviewError: DomainUnderlyingError {

    case nameNotValid
    case budgetsListNotValid
    case budgetAlreadyExistsWith(name: String)
    case cannotAddBudget
    case cannotDeleteBudgets
    case transactionsListNotValid

    var id: String {
        return "YearlyBudgetOverview"
    }

    var description: String {
        switch self {
        case .nameNotValid:
            return "Name not valid!"
        case .budgetsListNotValid:
            return "Budget list not valid!"
        case .budgetAlreadyExistsWith(let name):
            return "A budget named: \(name) already exists"
        case .cannotAddBudget:
            return "Cannot add budget"
        case .cannotDeleteBudgets:
            return "Cannot delete budgets"
        case .transactionsListNotValid:
            return "The list of transactions is not valid"
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
    case iconSystemNameNotValid
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
        case .iconSystemNameNotValid:
            return "Please use a valid icon system name"
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
        case .multipleSlicesWithSameName:
            return AccessibilityIdentifier.Error.sameNameError
        case .sliceAlreadyExistsWith:
            return AccessibilityIdentifier.Error.sameNameError
        case .thereMustBeAtLeastOneSlice:
            return AccessibilityIdentifier.Error.invalidSlicesError
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
    case schedulesNotFound
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
        case .schedulesNotFound:
            return "Schedule not found"
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

enum TransactionError: DomainUnderlyingError {
    case budgetSliceIsMissing
    case amountNotValid

    var id: String {
        return "Transaction"
    }

    var description: String {
        switch self {
        case .budgetSliceIsMissing:
            return "The budget slice is missing"
        case .amountNotValid:
            return "The amount is not valid"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        default:
            return AccessibilityIdentifier.Error.someError
        }
    }
}

enum StorageProviderError: DomainUnderlyingError {
    case overviewEntityNotFound
    case budgetEntityNotFound
    case cannotCreateBudgetWithEntity
    case underlying(error: Error)

    var id: String {
        return "Storage provider"
    }

    var description: String {
        switch self {
        case .overviewEntityNotFound:
            return "The overview you're looking for is missing"
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
