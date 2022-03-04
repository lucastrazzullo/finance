//
//  AmountTextField.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/11/2021.
//

import SwiftUI

struct AmountTextField: View {

    @Binding var amountValue: String

    let title: String
    let prompt: Text?

    var body: some View {
        TextField(title, text: $amountValue, prompt: prompt)
            .keyboardType(.decimalPad)
            .padding(.vertical)
    }
}

struct AmountTextField_Previews: PreviewProvider {
    static var previews: some View {
        AmountTextField(amountValue: .constant(""), title: "Amount", prompt: nil).padding()
    }
}
