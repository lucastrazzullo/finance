//
//  AmountTextField.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/11/2021.
//

import SwiftUI

struct AmountTextField: View {

    @Binding var amountValue: Decimal?

    let title: String

    var body: some View {
        TextField(title, value: $amountValue, format: .currency(code: Locale.current.currencyCodeOrDefault))
            .keyboardType(.decimalPad)
            .padding(.vertical)
    }
}

struct AmountTextField_Previews: PreviewProvider {
    static var previews: some View {
        AmountTextField(amountValue: .constant(100), title: "Amount").padding()
    }
}
