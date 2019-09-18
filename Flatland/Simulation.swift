//
//  Simulation.swift
//  Flatland
//
//  Created by Jon Tingvold on 18.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

class Simulation {
    static let board = Board(boardSize: (x: 10, y: 10))
    
    var foodsEaten: Int { return board.numberOfFoodsEaten   }
    var poisonEaten: Int { return board.numberOfPoisonEaten   }
    var board: Board
    var agent: IntelligentFlatlandAgent
    
    init(agent: IntelligentFlatlandAgent, board: Board) {
        self.agent = agent
        self.board = board
    }
    
    func decideAndMove() {
        let agentInfo = AgentInformation.init(board: board)
        let relativeDirection = agent.decide(agentInfo)
        board.move(relativeDirection)
    }
    
    func run(generations generations: Int) {
        for _ in 0..<generations {
            decideAndMove()
        }
    }
}