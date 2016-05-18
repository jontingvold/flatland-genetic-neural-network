//
//  TestANN.swift
//  Flatland
//
//  Created by Jon Tingvold on 18.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import XCTest

class TestANN: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func ann(layers: [Int], input: [Double]) -> [Double] {
        let numberOfWeights = ANN.totalNumberOfWeights(layers)
        let flattendWeights = (0..<numberOfWeights).map { _ in Random.double() }
        let ann = ANN(layers: layers, flattendWeights: flattendWeights)
        
        let output = ann.compute(input)
        
        return output
    }
    
    func testDimentions() {
        let layers = [2,2]
        let input = (0..<layers[0]).map { _ in Random.double() }
        let output = ann(layers, input: input)
        assert(output.count == layers.last)
    }

    func testDimentions2() {
        let layers = [2,10,2]
        let input = (0..<layers[0]).map { _ in Random.double() }
        let output = ann(layers, input: input)
        assert(output.count == layers.last)
    }
    
    func testDimentions3() {
        let layers = [10,30,10,10,100,5]
        let input = (0..<layers[0]).map { _ in Random.double() }
        let output = ann(layers, input: input)
        assert(output.count == layers.last)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
