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
        let month: Month
    }

    enum Configuration: AmountHolder, Equatable {
        case montly(amount: MoneyValue)
        case scheduled(schedules: [Schedule])

        var amount: MoneyValue {
            switch self {
            case .montly(let amount):
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

        try self.init(name: name, configuration: .montly(amount: monthlyAmount))
    }

    init(id: UUID = .init(), name: String, configuration: Configuration) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetSlice(error: .nameNotValid)
        }
        if case .scheduled(let schedules) = configuration, schedules.count == 0 {
            throw DomainError.budgetSlice(error: .thereMustBeAtLeastOneSchedule)
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
            throw DomainError.budgetSlice(error: .scheduleAlreadyExistsFor(month: schedule.month.name))
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
