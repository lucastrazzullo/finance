//
//  Subcategory.swift
//  Finance
//
//  Created by Luca Strazzullo on 10/01/2022.
//

import Foundation

struct Subcategory: Identifiable, Hashable {
    let id: UUID = .init()
    let name: String
    let category: Category.ID
}
