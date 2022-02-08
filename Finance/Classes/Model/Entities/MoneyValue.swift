//
//  MoneyValue.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import Foundation

struct MoneyValue {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    let value: Decimal

    var localizedDescription: String {
        return Self.formatter.string(from: value as NSDecimalNumber) ?? Self.unknownSymbol
    }

    static var unknownSymbol: String = "--"

    static var zero: Self {
        return MoneyValue(value: 0)
    }

    static func value(_ value: Decimal) -> Self {
        return MoneyValue(value: value)
    }

    static func string(_ string: String) -> Self? {
        guard let decimal = try? Decimal(string, format: .currency(code: Locale.current.currencyCodeOrDefault)) else {
            return nil
        }

        return .value(decimal)
    }

    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        return .value(lhs.value + rhs.value)
    }

    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        return .value(lhs.value - rhs.value)
    }

    static func *(_ lhs: Self, _ rhs: Self) -> Self {
        return .value(lhs.value * rhs.value)
    }
}

extension MoneyValue: Comparable {
    static func < (lhs: MoneyValue, rhs: MoneyValue) -> Bool {
        lhs.value < rhs.value
    }
}
