//
//  InlineErrorView.swift
//  Finance
//
//  Created by Luca Strazzullo on 28/01/2022.
//

import SwiftUI

struct InlineErrorView: View {

    let error: DomainError

    var body: some View {
        Text(error.description)
            .font(.caption2)
            .foregroundColor(.orange)
            .accessibilityIdentifier(error.accessibilityIdentifier)
    }
}

// MARK: - Previews

struct InlineErrorView_Previews: PreviewProvider {
    static var previews: some View {
        InlineErrorView(error: .budget(error: .amountNotValid))
    }
}
