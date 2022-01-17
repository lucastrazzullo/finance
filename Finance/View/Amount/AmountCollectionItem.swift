//
//  CapsuleView.swift
//  Finance
//
//  Created by Luca Strazzullo on 01/12/2021.
//

import SwiftUI

struct AmountCollectionItem: View {

    let title: String
    let caption: String?
    let amount: MoneyValue?
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text(title).font(.caption)
                AmountView(amount: amount).font(.body.bold())
            }

            if let caption = caption {
                Text(caption).font(.caption2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(12, antialiased: true)
    }
}

// MARK: - Previews

struct CapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        AmountCollectionItem(title: "Title",
                             caption: "Caption",
                             amount: .value(10.23),
                             color: .yellow)
    }
}
