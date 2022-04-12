//
//  DefaultToolbar.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct DefaultToolbar: View {

    let title: String
    let subtitle: String?

    var body: some View {
        VStack {
            Text(title).font(.title2.bold())

            if let subtitle = subtitle {
                Text(subtitle).font(.caption)
            }
        }
    }

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
