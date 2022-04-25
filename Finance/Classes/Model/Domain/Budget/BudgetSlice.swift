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

        init(amount: MoneyValue, month: Int) throws {
            guard amount > .zero else {
                throw DomainError.budgetSlice(error: .amountNotValid)
            }
            guard (1...12).contains(month) else {
                throw DomainError.budgetSlice(error: .scheduleMonthNotValid)
            }
            self.amount = amount
            self.month = month
        }
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

    init(id: UUID, name: String, configuration: Configuration) throws {
        guard !name.isEmpty else {
            throw DomainError.budgetSlice(error: .nameNotValid)
        }
        switch configuration {
        case .scheduled(let schedules) where schedules.isEmpty:
            throw DomainError.budgetSlice(error: .thereMustBeAtLeastOneSchedule)
        case .monthly:
            break
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
}

extension Array where Element == BudgetSlice {

    func containsDuplicates() -> Bool {
        let allNames = self.map(\.name)
        let uniqueNames = Set(allNames)
        return allNames.count > uniqueNames.count
    }

    func with(identifier: BudgetSlice.ID) -> BudgetSlice? {
        return self.first(where: { $0.id == identifier })
    }

    func at(offsets: IndexSet) -> [BudgetSlice] {
        return NSArray(array: self).objects(at: offsets) as? [BudgetSlice] ?? []
    }
}
