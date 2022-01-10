//
//  Category.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct Category: Identifiable, Hashable {
    let id: UUID = .init()
    let name: String
}
