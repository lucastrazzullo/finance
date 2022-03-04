//
//  BudgetSlice.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct BudgetSlice: Identifiable, Hashable, AmountHolder {

    struct ScheduledAmount: AmountHolder, Equatable {
        let amount: MoneyValue
        let month: Month
    }

    enum Configuration: AmountHolder, Equatable {
        case montly(amount: MoneyValue)
        case scheduled(schedules: [ScheduledAmount])

        var amount: MoneyValue {
            switch self {
            case .montly(let amount):
                return .value(amount.value * 12)
            case .scheduled(let schedules):
                return schedules.totalAmount
            }
        }
    }

    let id: UUID
    let name: String
    let configuration: Configuration

    var amount: MoneyValue {
        return configuration.amount
    }

    // MARK: Object life cycle

    init(id: UUID, name: String, monthlyAmount: String) throws {
        guard let monthlyAmount = MoneyValue.string(monthlyAmount) else {
            throw DomainError.budgetSlice(error: .amountNotValid)
        }

        try self.init(id: id, name: name, configuration: .montly(amount: monthlyAmount))
    }

    init(id: UUID, name: String, configuration: Configuration) throws {
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

    static func canAdd(schedule: ScheduledAmount, to list: [ScheduledAmount]) throws {
        guard !list.contains(where: { $0.month == schedule.month }) else {
            throw DomainError.budgetSlice(error: .scheduleAlreadyExistsFor(month: schedule.month.name))
        }
    }

    static func canRemove(schedule: ScheduledAmount, from list: [ScheduledAmount]) throws {
        guard list.contains(where: { $0.month == schedule.month }) else {
            throw DomainError.budgetSlice(error: .scheduleDoesntExistFor(month: schedule.month.name))
        }
        guard list.count > 1 else {
            throw DomainError.budgetSlice(error: .thereMustBeAtLeastOneSchedule)
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
