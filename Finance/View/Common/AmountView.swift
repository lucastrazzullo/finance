//
//  AmountView.swift
//  Finance
//
//  Created by luca strazzullo on 24/11/21.
//

import SwiftUI

struct AmountView: View {

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    let amount: MoneyValue?

    var text: String {
        if let amount = amount, let text = formatter.string(from: amount.value as NSDecimalNumber) {
            return text
        } else {
            return "--"
        }
    }

    var body: some View {
        Text(text)
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        AmountView(amount: .value(1000.12))
    }
}
