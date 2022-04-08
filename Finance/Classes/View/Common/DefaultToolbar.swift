//
//  DefaultToolbar.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct DefaultToolbar: ToolbarContent {

    let title: String
    let subtitle: String

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            VStack(alignment: .leading) {
                Text(title).font(.title2.bold())
                Text(subtitle).font(.caption)
            }
        }
    }
}
