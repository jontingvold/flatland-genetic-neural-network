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
    
    override func didMoveToView(view: SKView) {
        GameScene.singleton = self
        
        size  = view.bounds.size
        SKSceneScaleMode.ResizeFill
        backgroundColor = NSColor(white: 1.0, alpha: 1.0)
        setupMap()
    }
    
    func setupMap() {
        let tileSizeX = ((size.width - borderSize) / CGFloat(boardSize.x)) - borderSize
        let tileSizeY = ((size.height - borderSize) / CGFloat(boardSize.y)) - borderSize
        let tileColor = SKColor.lightGrayColor()
        
        tiles = (0..<boardSize.y).map { i in
            return (0..<boardSize.x).map { j in
                let tile = SKSpriteNode(color: tileColor, size: CGSize(width: tileSizeX, height: tileSizeY))
                tile.anchorPoint = CGPointZero
                
                let x = borderSize + CGFloat(j) * (tile.size.width + borderSize)
                let y = (size.height + borderSize) - (borderSize + CGFloat(i+1) * (tile.size.height + borderSize))
                
                tile.position = CGPoint(x: x, y: y)
                self.addChild(tile)
                
                return tile
            }
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
        case .Agent:
            tiles[i][j].color = SKColor.blueColor()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for i in 0..<boardSize.y {
            for j in 0..<boardSize.x {
                updateTile(i: i, j: j)
            }
        }
        
        let window = view!.window as! GameSceneWindow
        window.foodsEaten.stringValue = String(board.numberOfFoodsEaten)
        window.poisenEaten.stringValue = String(board.numberOfPoisonEeaten)
    }
    
    override func keyDown(theEvent: NSEvent) {
        let keyCode = theEvent.keyCode
        
        switch keyCode {
        case 123: // Left
            board.moveLeft()
        case 124: // Right
            board.moveRight()
        case 125: // Down
            board.moveDown()
        case 126: // Up
            board.moveUp()
        default: break
        }
    }
}
