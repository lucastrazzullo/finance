//
//  AmountListItem.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct AmountListItem: View {

    let label: String
    let amount: MoneyValue

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            AmountView(amount: amount)
        }
    }
}

// MARK: - Previews

struct AmountListItem_Previews: PreviewProvider {
    static var previews: some View {
        AmountListItem(label: "Label", amount: .value(100))
    }
}
