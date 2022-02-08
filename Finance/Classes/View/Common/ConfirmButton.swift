//
//  ConfirmButton.swift
//  Finance
//
//  Created by Luca Strazzullo on 01/12/2021.
//

import SwiftUI

struct ConfirmButton: View {

    let action: () -> ()

    var body: some View {
        Button(action: action, label: {
            Text("Confirm")
                .frame(maxWidth: .infinity)
                .padding(.vertical)
        })
        .buttonStyle(BorderedButtonStyle())
    }
}

// MARK: - Previews

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmButton(action: {})
    }
}
