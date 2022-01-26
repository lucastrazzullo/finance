//
//  ErrorView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct ErrorView: View {

    enum Option {
        case dismiss
    }

    let error: DomainError
    let options: [Option]
    let onSubmit: (Option) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(makeErrorDescription(error: error))

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button(role: .cancel, action: { onSubmit(option) }) {
                        Text(makeOptionDescription(option: option))
                    }
                }
            }
        }
        .padding()
    }

    // MARK: Private factory methods

    private func makeErrorDescription(error: DomainError) -> String {
        switch error {
        case .budgets(let error):
            switch error {
            case .budgetAlreadyExistsWith(let name):
                return "A budget named: \(name) already exists."
            case .budgetDoesntExist:
                return "The budget you are looking for doesn't exist"
            }
        case .budget(let error):
            switch error {
            case .sliceAlreadyExistsWith(let name):
                return "A slice named: \(name) already exists."
            case .sliceDoesntExist:
                return "The slice you're trying to modify or delete doesn't exist"
            case .thereMustBeAtLeastOneSlice:
                return "There must be at least one slice."
            case .nameNotValid:
                return "Please use a valid name"
            case .amountNotValid:
                return "Please use a valid amount"
            case .cannotUpdateTheBudget:
                return "This budget cannot be updated!"
            }
        case .budgetSlice(let error):
            switch error {
            case .nameNotValid:
                return "Please use a valid name"
            case .amountNotValid:
                return "Please use a valid amount"
            }
        case .budgetProvider(let error):
            switch error {
            case .budgetEntityNotFound:
                return "The budget you're looking for is missing"
            case .cannotCreateBudgetWithEntity:
                return "Cannot generate budget with entity"
            case .underlying(_):
                return "Something went wrong!"
            }
        case .underlying(_):
            return "Something went wrong!"
        }
    }

    private func makeOptionDescription(option: Option) -> String {
        switch option {
        case .dismiss:
            return "Ok"
        }
    }
}

// MARK: - Previews

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: .budgets(error: .budgetAlreadyExistsWith(name: "BudgetName")), options: [.dismiss]) { _ in }
    }
}
