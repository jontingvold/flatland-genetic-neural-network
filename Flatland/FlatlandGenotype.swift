//
//  FlatlandGenotype.swift
//  Flatland
//
//  Created by Jon Tingvold on 18.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

class FlatlandGenotype: Genotype {
    static var layers = [6, 30, 3]
    static var length = 3
    static var splitRandom = true
    static var mutationProbability = 0.2
    static var mutationStd = 0.3
    
    var vector: [Double]
    var description: String {
        let string: String = vector.reduce("") {
            return $0 + ", " + $1.f3()
        }
        
        return string
    }
    
    var length: Int {
        return vector.count
    }
    
    /// Create random genotype
    required init() {
        vector = (0..<FlatlandGenotype.length).map {_ in
            return FlatlandGenotype.getRandomGene()
        }
    }
    
    
    /// Copy genotype
    required init(genotype: Genotype) {
        let gtype = genotype as! FlatlandGenotype
        vector = gtype.vector.map {
            return $0
        }
        mutate()
    }
    
    /// Copy genotype
    required init(mother: Genotype, father: Genotype) {
        let m = mother as! FlatlandGenotype
        let f = father as! FlatlandGenotype
        
        vector = FlatlandGenotype.crossover(m.vector, father: f.vector)
        mutate()
    }
    
    static func getRandomGene() -> Double {
        return Random.double() * 2 - 1
    }
    
    static func crossover<T>(mother: [T], father: [T]) -> [T] {
        var vector = [T]()
        
        let count = min(mother.count, father.count)
        
        let randomIndex = Int(Random.float() * Float(count))
        let middleIndex = Int(count/2)
        let splitIndex = splitRandom ? randomIndex : middleIndex
        
        let isMotherFirst = Random.isTrue(probability: 0.5)
        
        if(isMotherFirst) {
            vector += [T](mother[0..<splitIndex])
            vector += [T](father[splitIndex..<father.count])
        } else {
            vector += [T](father[0..<splitIndex])
            vector += [T](mother[splitIndex..<mother.count])
        }
        
        return vector
    }
    
    func mutate() {
        vector = vector.map {
            let generateNew = Random.isTrue(probability: FlatlandGenotype.mutationProbability)
            
            if generateNew {
                return randomSmallValueChange($0)
            }else {
                return $0
            }
        }
    }
    
    func randomSmallValueChange(value: Double) -> Double {
        let newValue = value + Random.gaussian(mean: 0.0, std: FlatlandGenotype.mutationStd)
        let between0and1 = max(-10.0, min(newValue, 10.0))
        return between0and1
    }
}