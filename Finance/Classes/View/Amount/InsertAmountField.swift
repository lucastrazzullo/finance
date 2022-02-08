//
//  InsertAmountField.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/11/2021.
//

import SwiftUI

struct InsertAmountField: View {

    @Binding var amountValue: String

    let title: String
    let prompt: Text?

    var body: some View {
        TextField(title, text: $amountValue, prompt: prompt)
            .keyboardType(.decimalPad)
            .padding(.vertical)
    }
}

struct AmountField_Previews: PreviewProvider {
    static var previews: some View {
        InsertAmountField(amountValue: .constant(""), title: "Amount", prompt: nil).padding()
    }
}
