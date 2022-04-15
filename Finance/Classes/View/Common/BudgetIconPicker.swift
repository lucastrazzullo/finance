//
//  SystemIconPicker.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct SystemIconPicker: View {

    @Binding var selection: SystemIcon

    let label: String

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(SystemIcon.allCases, id: \.self) { name in
                Image(systemName: name.rawValue)
            }
        }
        .pickerStyle(.menu)
        .symbolRenderingMode(.hierarchical)
        .accentColor(.primary)
    }
}

struct SystemIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        SystemIconPicker(selection: .constant(SystemIcon.default), label: "Icon")
    }
}
