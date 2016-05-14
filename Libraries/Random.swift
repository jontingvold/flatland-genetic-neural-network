//
//  Random.swift
//  GA
//
//  Created by Jon Tingvold on 05.02.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

class Random {
    static func int(num: Int) -> Int {
        let converted = UInt32(num)
        return Int(arc4random_uniform(converted))
    }
    
    static func gaussian(mean mean: Double, std: Double) -> Double {
        let u1 = Double(arc4random()) / Double(UINT32_MAX) // uniform distribution
        let u2 = Double(arc4random()) / Double(UINT32_MAX); // uniform distribution
        let f1 = sqrt(-2 * log(u1));
        let f2 = 2 * M_PI * u2;
        let g1 = f1 * cos(f2); // gaussian distribution
        
        let randomG = mean + g1 * std
        return randomG
    }
    
    /// Double between 0 and to
    static func double(to: Double) -> Double {
        return Random.double() * to
    }
    
    /// Float between 0 and 1
    static func float() -> Float {
        return Float(arc4random())/Float(UInt32.max)
    }
    
    /// Double between 0 and 1
    static func double() -> Double {
        return Double(arc4random())/Double(UInt32.max)
    }
    
    /// True with probability p
    static func isTrue(probability probability: Double) -> Bool {
        return Random.double() < probability
    }
    
    static func choice<T>(choices: [T]) -> T {
        let offset = Random.int(choices.count)
        return choices[offset]
    }
    
    static func shuffle(choices: Array<Any>) -> Array<Any> {
        // Copy it to produce a mutable version.
        var copied = choices
        let len = copied.count
        
        // Half-open range, so we don't overflow the array length.
        for i in 0..<len {
            let roffset = Random.int(len - i) + i
            swap(&copied[i], &copied[roffset])
        }
        
        return copied
    }
}