//
//  Board.swift
//  Flatland
//
//  Created by Jon Tingvold on 12.05.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

enum RelativeDirection: Int {
    case Forward = 0
    case Left = 1
    case Right = 2
}

enum Direction: Int {
    case North = 0
    case East = 1
    case South = 2
    case West = 3
    
    func right() -> Direction {
        if (self == .West) {
            return .North
        } else {
            return Direction(rawValue: self.rawValue + 1)!
        }
    }
    
    func left() -> Direction {
        if (self == .North) {
            return .West
        } else {
            return Direction(rawValue: self.rawValue - 1)!
        }
    }
}

enum BoardTile {
    case Empty
    case Food
    case Poison
}

class AgentPosition {
    var i: Int
    var j: Int
    var direction: Direction
    
    init(i: Int, j: Int, direction: Direction) {
        self.i = i
        self.j = j
        self.direction = direction
    }
    
    func right() {
        direction = direction.right()
    }
    
    func left() {
        direction = direction.left()
    }
    
    func forward(boardSize boardSize: VectorXY) {
        var i = self.i
        var j = self.j
        
        switch(direction) {
        case .North:
            i -= 1
        case .East:
            j += 1
        case .South:
            i += 1
        case .West:
            j -= 1
        }
        
        if i == boardSize.y { i = 0}
        else if i == -1 { i = boardSize.y - 1}
        if j == boardSize.x { j = 0}
        else if j == -1 { j = boardSize.x - 1}
        
        self.i = i
        self.j = j
    }
}
    
typealias VectorXY = (x: Int, y: Int)
typealias VectorIJ = (i: Int, j: Int)

class Board {
    var board: [[BoardTile]]
    var agentPosition: VectorIJ
    var agentDirection: Direction
    var moves = 0
    
    var numberOfFoods = 0
    var numberOfPoison = 0
    var numberOfFoodsEaten = 0
    var numberOfPoisonEaten = 0
    
    var boardSize: VectorXY {
        return (x: board[0].count, y: board.count)
    }
    let probabilityFood = 0.33
    let remainingProbabilityPoison = 0.33
    
    init(boardSize: (x: Int, y: Int)) {
        board = [[BoardTile]]() // Dummy init
        agentPosition = (i: 0, j: 0) // Dummy init
        agentDirection = .North
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
    
    init(instance: Board) {
        self.board = instance.board.map {
            return $0.map { tile in
                return tile
            }
        }
        
        self.agentPosition = instance.agentPosition
        self.agentDirection = instance.agentDirection
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
        agentPosition = (i: random_i, j: random_j)
        board[random_i][random_j] = BoardTile.Empty
        agentDirection = Direction(rawValue: Random.int(4))!
    }
    
    func getTile(position: VectorIJ) -> BoardTile {
        return board[position.i][position.j]
    }
    
    func agentPositionTo(direction: Direction) -> VectorIJ {
        var i = agentPosition.i
        var j = agentPosition.j
        
        switch(direction) {
        case .North:
            i -= 1
        case .East:
            j += 1
        case .South:
            i += 1
        case .West:
            j -= 1
        }
        
        if i == boardSize.y { i = 0}
        else if i == -1 { i = boardSize.y - 1}
        if j == boardSize.x { j = 0}
        else if j == -1 { j = boardSize.x - 1}
        
        return (i: i, j: j)
    }
    
    /// Move Agent
    func move(direction: RelativeDirection) {
        switch direction {
        case .Forward:
            moveForward()
        case .Left:
            moveLeft()
        case .Right:
            moveRight()
        }
    }
    
    func moveForward() {
        agentPosition = agentPositionTo(agentDirection)
        
        switch board[agentPosition.i][agentPosition.j] {
        case .Food:
            numberOfFoodsEaten += 1
        case .Poison:
            numberOfPoisonEaten += 1
        default:
            break
        }
        
        board[agentPosition.i][agentPosition.j] = BoardTile.Empty
        moves += 1
    }
    
    func moveLeft() {
        agentDirection = agentDirection.left()
        moves += 1
    }
    
    func moveRight() {
        agentDirection = agentDirection.right()
        moves += 1
    }
    

    
    var allFoodsEaten: Bool {
        return numberOfFoods == numberOfFoodsEaten
    }
}

extension Board {
    func copy() -> Board {
        return Board.init(instance: self)
    }
}
