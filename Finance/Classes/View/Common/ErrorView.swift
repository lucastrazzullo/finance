//
//  ErrorView.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import SwiftUI

struct ErrorView: View {

    struct Action {
        let label: String
        let handler: () -> Void
    }

    let error: DomainError
    let action: Action

    var body: some View {
        VStack {
            Text(error.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .accessibilityIdentifier(error.accessibilityIdentifier)

            Button(action: action.handler) {
                Text(action.label)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            error: .storageProvider(error: .overviewEntityNotFound),
            action: .init(label: "Retry", handler: {})
        )
    }
}
