//
//  Phenotype.swift
//  GA
//
//  Created by Jon Tingvold on 05.02.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

protocol Phenotype: CustomStringConvertible {
    var genotype: Genotype { get }
    var fitness: Double { get }
    var isGoalState: Bool { get }
    
    init(genotype: Genotype)
}