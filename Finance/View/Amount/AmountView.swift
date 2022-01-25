//
//  AmountView.swift
//  Finance
//
//  Created by luca strazzullo on 24/11/21.
//

import SwiftUI

struct AmountView: View {

    let amount: MoneyValue?

    var body: some View {
        Text(amount?.localizedDescription ?? MoneyValue.unknownSymbol)
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        AmountView(amount: .value(1000.12))
    }
}
