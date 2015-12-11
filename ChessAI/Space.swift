//
//  Space.swift
//  ChessAI
//
//  Created by Liam Cain on 11/22/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Space: SKSpriteNode {
    
    var bColor: Side
    var space: (Int, Int)
    let highlight: SKSpriteNode
    
    init(color: Side, space: (Int, Int)) {
        self.bColor = color
        self.space = space
        
        highlight = SKSpriteNode(imageNamed: "board-highlight")
        highlight.colorBlendFactor = 1.0
        highlight.color = SKColor.blackColor()
        highlight.zPosition = ZPOSITION_BOARD_HIGHLIGHT
        highlight.hidden = true
        
        let texture = SKTexture(imageNamed: "board-space")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        self.colorBlendFactor = 1.0
        if bColor == .BLACK {
            self.color = BOARD_BLACK
        } else {
            self.color = BOARD_WHITE
        }
        self.zPosition = ZPOSITION_BOARD_SPACE
        addChild(highlight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prevMove() {
        if bColor == .BLACK {
            self.color = BOARD_BLACK_HIGHLIGHT
        } else {
            self.color = BOARD_WHITE_HIGHLIGHT
        }
    }
    
    func clearPrevMove() {
        if bColor == .BLACK {
            self.color = BOARD_BLACK
        } else {
            self.color = BOARD_WHITE
        }
    }
    
    func validMove() {
        highlight.hidden = false
    }
    
    func invalidMove() {
        highlight.hidden = true
    }
    
    func resetColor() {
        removeAllActions()
        if bColor == .BLACK {
            self.color = BOARD_BLACK
        } else {
            self.color = BOARD_WHITE
        }
    }
    
    func flash() {
        let speed = 0.2
        let waitTime = 0.2
        
        if bColor == .BLACK {
            let on   = SKAction.colorizeWithColor(BOARD_WHITE, colorBlendFactor: 1.0, duration: speed)
            let off  = SKAction.colorizeWithColor(BOARD_BLACK, colorBlendFactor: 1.0, duration: speed)
            let wait = SKAction.waitForDuration(waitTime)
            let seq  = SKAction.sequence([on, wait, off, wait])
            runAction(SKAction.repeatActionForever(seq))
        } else {
            let on   = SKAction.colorizeWithColor(BOARD_BLACK, colorBlendFactor: 1.0, duration: speed)
            let off  = SKAction.colorizeWithColor(BOARD_WHITE, colorBlendFactor: 1.0, duration: speed)
            let wait = SKAction.waitForDuration(waitTime)
            let seq  = SKAction.sequence([on, wait, off, wait])
            runAction(SKAction.repeatActionForever(seq))
        }
    }

    func lightFlash() {
        let speed = 0.2
        let waitTime = 0.2
        
        if bColor == .BLACK {
            let on   = SKAction.colorizeWithColor(BOARD_BLACK_HIGHLIGHT, colorBlendFactor: 1.0, duration: speed)
            let off  = SKAction.colorizeWithColor(BOARD_BLACK, colorBlendFactor: 1.0, duration: speed)
            let wait = SKAction.waitForDuration(waitTime)
            let seq  = SKAction.sequence([on, wait, off, wait])
            runAction(SKAction.repeatActionForever(seq))
        } else {
            let on   = SKAction.colorizeWithColor(BOARD_WHITE_HIGHLIGHT, colorBlendFactor: 1.0, duration: speed)
            let off  = SKAction.colorizeWithColor(BOARD_WHITE, colorBlendFactor: 1.0, duration: speed)
            let wait = SKAction.waitForDuration(waitTime)
            let seq  = SKAction.sequence([on, wait, off, wait])
            runAction(SKAction.repeatActionForever(seq))
        }
    }

}