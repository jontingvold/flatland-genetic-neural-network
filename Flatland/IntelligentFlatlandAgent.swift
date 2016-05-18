//
//  IntelligentFlatlandAgent.swift
//  Flatland
//
//  Created by Jon Tingvold on 18.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

struct AgentInformation {
    var foodForward: Bool
    var foodLeft: Bool
    var foodRight: Bool
    
    var poisonForward: Bool
    var poisionLeft: Bool
    var poisonRight: Bool
    
    init(board: Board) {
        foodForward = board.getTile(board.agentPositionTo(board.agentDirection)) == BoardTile.Food
        foodLeft = board.getTile(board.agentPositionTo(board.agentDirection.left())) == BoardTile.Food
        foodRight = board.getTile(board.agentPositionTo(board.agentDirection.right())) == BoardTile.Food
        
        poisonForward = board.getTile(board.agentPositionTo(board.agentDirection)) == BoardTile.Poison
        poisionLeft = board.getTile(board.agentPositionTo(board.agentDirection.left())) == BoardTile.Poison
        poisonRight = board.getTile(board.agentPositionTo(board.agentDirection.right())) == BoardTile.Poison
    }
    
    func asVector() -> [Double] {
        var vector = [Double]()
        vector.append(Double(foodForward))
        vector.append(Double(foodLeft))
        vector.append(Double(foodRight))
            
        vector.append(Double(poisonForward))
        vector.append(Double(poisionLeft))
        vector.append(Double(poisonRight))
            
        return vector
    }
}

class IntelligentFlatlandAgent {
    let ann: ANN
    
    init(layers: [Int], weights: [Double]) {
        ann = ANN(layers: layers, flattendWeights: weights)
    }
    
    func decide(input: AgentInformation) -> RelativeDirection {
        let output = ann.compute(input.asVector())
        let agentDirection = RelativeDirection(rawValue: output.maxIndex!)!
        return agentDirection
    }
}