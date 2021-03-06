//
//  AccessibilityIdentifier.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/02/2022.
//

import Foundation

enum AccessibilityIdentifier {

    enum Error {
        static let someError = "SomeError"

        static let sameNameError = "SameNameError"
        static let invalidNameError = "InvalidNameError"
        static let invalidAmountError = "InvalidAmountError"
        static let invalidSlicesError = "InvalidSlicesError"
    }

    enum TransactionsListView {
        static let addTransactionButton = "AddTransactionButton"
        static let transactionLink = "BudgetLink"
    }

    enum FinanceView {
        static let overviewTab = "OverviewTab"
        static let budgetsTab = "BudgetsTab"
        static let transactionsTab = "TransactionsTab"
    }

    enum BudgetsListView {
        static let addBudgetButton = "AddBudgetButton"
        static let budgetLink = "BudgetLink"
    }

    enum NewBudgetView {
        static let nameInputField = "BudgetNameInputField"
        static let addSliceButton = "AddSliceButton"
        static let sliceItem = "SliceItem"
        static let saveButton = "SaveBudgetButton"
    }

    enum NewSliceView {
        static let nameInputField = "SliceNameInputField"
        static let amountInputField = "SliceAmountInputField"
        static let saveButton = "SaveSliceButton"
    }

    enum NewTransactionView {
        static let descriptionInputField = "DescriptionInputField"
    }
}
