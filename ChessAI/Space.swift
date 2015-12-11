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
            self.color = SKColor(red: 0, green: 0.6, blue: 0.83, alpha: 1.0)
        } else {
            self.color = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        self.zPosition = ZPOSITION_BOARD_SPACE
        addChild(highlight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prevMove() {
        if bColor == .BLACK {
            self.color = SKColor(red: 0, green: 0.46, blue: 0.68, alpha: 1.0)
        } else {
            self.color = SKColor(red: 0.86, green: 0.92, blue: 1.0, alpha: 1.0)
        }
    }
    
    func clearPrevMove() {
        if bColor == .BLACK {
            self.color = SKColor(red: 0, green: 0.6, blue: 0.83, alpha: 1.0)
        } else {
            self.color = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    func validMove(){
        highlight.hidden = false
    }
    
    func invalidMove(){
        highlight.hidden = true
    }

}