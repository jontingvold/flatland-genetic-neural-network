//
//  ANN.swift
//  Flatland
//
//  Created by Jon Tingvold on 15.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

class ANN {
    let layers: [Int]
    
    var weights = [Matrix<Double>]()
    
    init(layers: [Int], flattendWeights: [Double]) {
        self.layers = layers
        
        let numberOfWeightsInLayer = ANN.numberOfWeights(layers)
        var index = 0
        
        // First layer is empty
        weights.append(Matrix(rows: 0, columns: 0, grid: [Double]()))
        
        for i in 1..<layers.count {
            let numberOfWeights = numberOfWeightsInLayer[i]
            
            let rows = layers[i]
            let columns = layers[i-1] + 1
            
            let range = index..<(index + numberOfWeights)
            let grid = Array(flattendWeights[range])
            
            let matrix = Matrix(rows: rows, columns: columns, grid: grid)
            weights.append(matrix)
            index += numberOfWeights
        }
    }
    
    static func numberOfWeights(layers: [Int]) -> [Int] {
        var numberOfWeights: [Int] = [0]
        
        for i in 1..<layers.count {
            let weightsInLayerI = layers[i] * (layers[i-1] + 1) // +1 because of bayes node
            numberOfWeights.append(weightsInLayerI)
        }
        
        return numberOfWeights
    }
    
    static func totalNumberOfWeights(layers: [Int]) -> Int {
        return sum(ANN.numberOfWeights(layers))
    }
    
    func compute(input: [Double]) -> [Double] {
        var a = [Matrix<Double>]()
        a.append(Matrix<Double>(rows: input.count, columns: 1, grid: input))
        
        for i in 1..<layers.count {
            let x = Matrix<Double>(rows: a[i-1].rows + 1, columns: 1, grid: a[i-1].grid + [1.0])
            a.append(activationFunction(weights[i] * x))
        }
        
        let output = a.last!.grid
        return output
    }
    
    func activationFunction(x: Double) -> Double {
        //return max(0, x)
        return Darwin.tanh(x)
    }
    
    func activationFunction(x: Matrix<Double>) -> Matrix<Double> {
        var matrix = x
        
        for i in 0..<x.rows {
            for j in 0..<x.columns {
                matrix[i, j] = activationFunction(matrix[i, j])
            }
        }
        return matrix
    }
}