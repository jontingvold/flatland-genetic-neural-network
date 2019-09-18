//
//  Double.swift
//  GA
//
//  Created by Jon Tingvold on 05.02.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

extension Double {
    func isClose(number: Double) -> Bool {
        let standardPresition = 1e-3
        return isClose(number, presition: standardPresition)
    }
    
    func isClose(number: Double, presition: Double) -> Bool {
        return abs(self - number) < presition
    }
    
    func f3() -> String {
        return String(format: "%.3f", self)
    }
}