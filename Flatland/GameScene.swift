//
//  GameScene.swift
//  Flatland
//
//  Created by Jon Tingvold on 12.05.2016.
//  Copyright (c) 2016 Jon Tingvold. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    static var singleton: GameScene?
    
    let boardSize = (x: 10, y: 10)
    let borderSize = CGFloat(2)
    var board = Board(boardSize: (x: 10, y: 10))
    var tiles = [[SKSpriteNode]]()
    var agent = SKSpriteNode()
    
    var tileSizeX = CGFloat(0)
    var tileSizeY = CGFloat(0)
    
    override func didMoveToView(view: SKView) {
        GameScene.singleton = self
        
        size  = view.bounds.size
        SKSceneScaleMode.ResizeFill
        backgroundColor = NSColor(white: 1.0, alpha: 1.0)
        
        tileSizeX = ((size.width - borderSize) / CGFloat(boardSize.x)) - borderSize
        tileSizeY = ((size.height - borderSize) / CGFloat(boardSize.y)) - borderSize
        
        setupMap()
    }
    
    func getTilePosition(i i: Int, j: Int) -> (x: CGFloat, y: CGFloat) {
        let x = borderSize + CGFloat(j) * (tileSizeX + borderSize)
        let y = (size.height + borderSize) - (borderSize + CGFloat(i+1) * (tileSizeY + borderSize))
        
        return (x: x, y: y)
    }
    
    func setupMap() {
        tiles = (0..<boardSize.y).map { i in
            return (0..<boardSize.x).map { j in
                let tileColor = SKColor.lightGrayColor()
                let tile = SKSpriteNode(color: tileColor, size: CGSize(width: tileSizeX, height: tileSizeY))
                tile.anchorPoint = CGPointZero
                
                let pos = getTilePosition(i: i, j: j)
                tile.position = CGPoint(x: pos.x, y: pos.y)
                
                self.addChild(tile)
                
                return tile
            }
        }
        
        agent = SKSpriteNode(imageNamed:"Spaceship")
        agent.setScale(0.1)
        updateAgent()
        self.addChild(agent)
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            let search = GASearcher()
            search.run()
            let bestPhenotype = search.generationStatistics.last!.bestIndividual as! FlatlandPhenotype
            let board = FlatlandPhenotype.scenarios.first!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.board = board
            }
            
            bestPhenotype.runSimulation(board, slow: true)
        }
    }
    
    func updateTile(i i: Int, j: Int) {
        switch board.board[i][j] {
        case .Empty:
            tiles[i][j].color = SKColor.lightGrayColor()
        case .Food:
            tiles[i][j].color = SKColor.greenColor()
        case .Poison:
            tiles[i][j].color = SKColor.redColor()
        }
    }
    
    func updateAgent() {
        let pos = getTilePosition(i: board.agentPosition.i, j: board.agentPosition.j)
        agent.position = CGPoint(x: pos.x + tileSizeX / 2, y: pos.y + tileSizeY / 2)
        let angle = Double(-1 * board.agentDirection.rawValue) * M_PI / 2
        agent.zRotation = CGFloat(angle)
        agent.setScale(0.15)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for i in 0..<boardSize.y {
            for j in 0..<boardSize.x {
                updateTile(i: i, j: j)
            }
        }
        updateAgent()
        
        let window = view!.window as! GameSceneWindow
        window.foodsEaten.stringValue = String(board.numberOfFoodsEaten)
        window.poisenEaten.stringValue = String(board.numberOfPoisonEaten)
        window.moves.stringValue = String(board.moves)
    }
    
    override func keyDown(theEvent: NSEvent) {
        let keyCode = theEvent.keyCode
        
        switch keyCode {
        case 123: // Left
            board.moveLeft()
        case 124: // Right
            board.moveRight()
        //case 125: // Down
        //    board.moveDown()
        case 126: // Up
            board.moveForward()
        default: break
        }
    }
}
