//
//  ErrorView.swift
//  Finance
//
//  Created by Luca Strazzullo on 13/04/2022.
//

import SwiftUI

struct ErrorView: View {

    let error: DomainError
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Text(error.description)
                .font(.body)
                .foregroundColor(.orange)
                .accessibilityIdentifier(error.accessibilityIdentifier)

            Button(action: retryAction) {
                Text("Retry")
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: .storageProvider(error: .overviewEntityNotFound), retryAction: {})
    }
}
