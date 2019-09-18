//
//  Common.swift
//  Flatland
//
//  Created by Jon Tingvold on 15.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

protocol Number
{
    func +(l: Self, r: Self) -> Self
    func -(l: Self, r: Self) -> Self
    func >(l: Self, r: Self) -> Bool
    func <(l: Self, r: Self) -> Bool
}

extension Double : Number {}
extension Float  : Number {}
extension Int    : Number {}

func sum<T:Number>(collection: [T]) -> T {
    var result = collection[0]
    for n in 1..<collection.count
    {
        result = result + collection[n]
    }
    return result
}


extension Array where Element:Comparable {
    var maxIndex : Int? {
        // Thanks Mike Ash, Jacob Bandes-Storch, Bas Broek
        return self.enumerate().maxElement({$1.element > $0.element})?.index
    }
}