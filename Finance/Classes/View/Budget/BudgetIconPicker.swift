//
//  BudgetIconPicker.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct BudgetIconPicker: View {

    @Binding var selection: String

    let label: String

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(SystemIcon.allCases, id: \.rawValue) { name in
                Image(systemName: name.rawValue)
            }
        }
        .pickerStyle(.menu)
        .symbolRenderingMode(.hierarchical)
        .accentColor(.primary)
    }
}

struct BudgetIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        BudgetIconPicker(selection: .constant(SystemIcon.default.rawValue), label: "Icon")
    }
}
