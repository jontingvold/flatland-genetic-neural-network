//
//  Genotype.swift
//  GA
//
//  Created by Jon Tingvold on 05.02.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

protocol Genotype: CustomStringConvertible {
    init()
    init(genotype: Genotype)
    init(mother: Genotype, father: Genotype)
}