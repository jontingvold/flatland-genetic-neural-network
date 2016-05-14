//
//  Board.swift
//  Flatland
//
//  Created by Jon Tingvold on 12.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

enum BoardTile {
    case Empty
    case Food
    case Poison
    case Agent
}

class Board {
    var board: [[BoardTile]]
    var agentPosition: (i: Int, j: Int)
    
    var numberOfFoods = 0
    var numberOfPoison = 0
    var numberOfFoodsEaten = 0
    var numberOfPoisonEeaten = 0
    
    var boardSize: (x: Int, y: Int) {
        return (x: board[0].count, y: board.count)
    }
    let probabilityFood = 0.33
    let remainingProbabilityPoison = 0.33
    
    init(boardSize: (x: Int, y: Int)) {
        board = [[BoardTile]]() // Dummy init
        agentPosition = (i: 0, j: 0) // Dummy init
        newRandomBoard(boardSize)
        
        numberOfFoods = board.reduce(0) { i, line in
            line.reduce(i) { i2, tile in
                if tile == BoardTile.Food {
                    return i2 + 1
                } else {
                    return i2
                }
            }
        }
        
        numberOfPoison = board.reduce(0) { i, line in
            line.reduce(i) { i2, tile in
                if tile == BoardTile.Poison {
                    return i2 + 1
                } else {
                    return i2
                }
            }
        }
    }
    
    init(board: [[BoardTile]], agentPosition: (i: Int, j: Int)) {
        self.board = board
        self.agentPosition = agentPosition
    }
    
    func copyJustBoard() -> Board {
        let boardCopy = board.map {
            return $0.map { tile in
                return tile
            }
        }
        
        return Board(board: boardCopy, agentPosition: agentPosition)
    }
    
    func newRandomBoard(boardSize: (x: Int, y: Int)) {
        board = (0..<boardSize.y).map { _ in
            return (0..<boardSize.x).map { _ in
                if Random.isTrue(probability: probabilityFood) {
                    return BoardTile.Food
                } else if Random.isTrue(probability: remainingProbabilityPoison) {
                    return BoardTile.Poison
                } else {
                    return BoardTile.Empty
                }
            }
        }
        
        let random_i = Random.int(boardSize.y)
        let random_j = Random.int(boardSize.x)
        moveAgentTo(i: random_i, j: random_j)
    }
    
    /// Move Agent
    func moveUp() {
        if agentPosition.i == 0 {
            moveAgentTo(i: boardSize.y - 1, j: agentPosition.j)
        } else {
            moveAgentTo(i: agentPosition.i - 1, j: agentPosition.j)
        }
    }
    func moveRight() {
        if agentPosition.j == boardSize.x - 1 {
            moveAgentTo(i: agentPosition.i, j: 0)
        } else {
            moveAgentTo(i: agentPosition.i, j: agentPosition.j + 1)
        }
    }
    func moveDown() {
        if agentPosition.i == boardSize.x - 1 {
            moveAgentTo(i: 0, j: agentPosition.j)
        } else {
            moveAgentTo(i: agentPosition.i + 1, j: agentPosition.j)
        }
    }
    func moveLeft() {
        if agentPosition.j == 0 {
            moveAgentTo(i: agentPosition.i, j: boardSize.y - 1)
        } else {
            moveAgentTo(i: agentPosition.i, j: agentPosition.j - 1)
        }
    }
    
    func moveAgentTo(i i: Int, j: Int) {
        board[agentPosition.i][agentPosition.j] = BoardTile.Empty
        agentPosition.i = i
        agentPosition.j = j
        
        switch board[i][j] {
        case BoardTile.Food:
            numberOfFoodsEaten += 1
        case BoardTile.Poison:
            numberOfPoisonEeaten += 1
        default: break
            
        }
        
        board[i][j] = BoardTile.Agent
    }
    
    var allFoodsEaten: Bool {
        return numberOfFoods == numberOfPoisonEeaten
    }
}