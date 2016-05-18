//
//  FlatlandPhenotype.swift
//  Flatland
//
//  Created by Jon Tingvold on 18.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

class FlatlandPhenotype: Phenotype {
    static var moves = 60
    static var scenarios = [Board(boardSize: (x: 10, y: 10)),
                           Board(boardSize: (x: 10, y: 10)),
                           Board(boardSize: (x: 10, y: 10)),
                           Board(boardSize: (x: 10, y: 10)),
                           Board(boardSize: (x: 10, y: 10))]
    
    let genotype: Genotype
    var genotypeAsFlatlandGenotype: FlatlandGenotype {
        return genotype as! FlatlandGenotype
    }
    
    var isGoalState = false
    var fitness: Double
    
    var description: String {
        return genotype.description
    }
    
    required init(genotype: Genotype) {
        self.genotype = genotype
        self.fitness = 0 // Dummy to initalize
        self.fitness = calcFitness()
    }
    
    internal func calcFitness() -> Double {
        var totalFitness = 0.0
        
        for board in FlatlandPhenotype.scenarios {
            let results = runSimulation(board.copy(), slow: false)
            let fitness = (Double(results.foodsEaten) - Double(results.poisonEaten) * 1.0)/Double(board.numberOfFoods)
            totalFitness += fitness
        }
        
        return totalFitness / Double(FlatlandPhenotype.scenarios.count)
    }
    
    func runSimulation(board: Board, slow: Bool) -> (foodsEaten: Int, poisonEaten: Int) {
        let agent = IntelligentFlatlandAgent(layers: FlatlandGenotype.layers, weights: genotypeAsFlatlandGenotype.vector)
        let simulation = Simulation(agent: agent, board: board)
        for _ in 0..<FlatlandPhenotype.moves {
            simulation.decideAndMove()
            if slow {
                NSThread.sleepForTimeInterval(0.25)
            }
        }
        let results = (foodsEaten: simulation.foodsEaten, poisonEaten: simulation.poisonEaten)
        return results
    }
    
    static func generateNewScenarios() {
        scenarios = [Board(boardSize: (x: 10, y: 10)),
                    Board(boardSize: (x: 10, y: 10)),
                    Board(boardSize: (x: 10, y: 10)),
                    Board(boardSize: (x: 10, y: 10)),
                    Board(boardSize: (x: 10, y: 10))]
    }
}