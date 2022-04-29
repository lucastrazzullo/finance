//
//  Array+Extensions.swift
//  Finance
//
//  Created by Luca Strazzullo on 21/01/2022.
//

import Foundation

extension Array where Element == UUID {

    func removeDuplicates() -> Array {
        let set = NSOrderedSet(array: self)
        return set.array.compactMap({ element -> UUID? in element as? UUID })
    }
}

extension Array where Element == Int {

    func removeDuplicates() -> Array {
        let set = NSOrderedSet(array: self)
        return set.array.compactMap({ element -> Int? in element as? Int })
    }
}
