//
//  Locale+Defaults.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/11/2021.
//

import Foundation

extension Locale {
    static let defaultCurrencyCode: String = "EUR"
    var currencyCodeOrDefault: String { Locale.current.currencyCode ?? Locale.defaultCurrencyCode }
}
