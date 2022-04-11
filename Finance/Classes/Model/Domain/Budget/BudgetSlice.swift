//
//  BudgetSlice.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct BudgetSlice: Identifiable, Hashable, AmountHolder {

    typealias ID = UUID

    struct Schedule: AmountHolder, Equatable {
        let amount: MoneyValue
        let month: Int
    }

    enum Configuration: AmountHolder, Equatable {
        case monthly(amount: MoneyValue)
        case scheduled(schedules: [Schedule])

        var amount: MoneyValue {
            switch self {
            case .monthly(let amount):
                return .value(amount.value * 12)
            case .scheduled(let schedules):
                return schedules.totalAmount
            }
        }
    }

    let id: Self.ID
    let name: String
    let configuration: Configuration

    var amount: MoneyValue {
        return configuration.amount
    }

    // MARK: Object life cycle

    init(name: String, monthlyAmount: String) throws {
        guard let monthlyAmount = MoneyValue.string(monthlyAmount) else {
            throw DomainError.budgetSlice(error: .amountNotValid)
        }

        try self.init(name: name, configuration: .monthly(amount: monthlyAmount))
    }

    init(id: UUID = .init(), name: String, configuration: Configuration) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetSlice(error: .nameNotValid)
        }
        switch configuration {
        case .monthly(let amount) where amount == .zero:
            throw DomainError.budgetSlice(error: .amountNotValid)
        case .scheduled(let schedules) where schedules.isEmpty:
            throw DomainError.budgetSlice(error: .thereMustBeAtLeastOneSchedule)
        default:
            break
        }

        self.id = id
        self.name = name
        self.configuration = configuration
    }

    // MARK: Hashable conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(amount.value)
    }

    // MARK: Helpers

    static func willAdd(schedule: Schedule, to list: [Schedule]) throws {
        guard !list.contains(where: { $0.month == schedule.month }) else {
            let monthName = Calendar.current.standaloneMonthSymbols[schedule.month - 1]
            throw DomainError.budgetSlice(error: .scheduleAlreadyExistsFor(month: monthName))
        }
    }
}

extension Array where Element == BudgetSlice {

    func containsDuplicates() -> Bool {
        let allNames = self.map(\.name)
        let uniqueNames = Set(allNames)
        return allNames.count > uniqueNames.count
    }
}
