//
//  Space.swift
//  ChessAI
//
//  Created by Liam Cain on 11/22/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Space: SKSpriteNode {
    
    enum Color {
        case WHITE
        case BLACK
    }
    
    var bColor: Color
    var space: (Int, Int)
    let highlight: SKSpriteNode
    
    init(color: Color, space: (Int, Int)) {
        self.bColor = color
        self.space = space
        
        highlight = SKSpriteNode(imageNamed: "board-highlight")
        highlight.colorBlendFactor = 1.0
        highlight.color = SKColor.blackColor()
        highlight.zPosition = ZPOSITION_BOARD_HIGHLIGHT
        highlight.hidden = true
        
        let texture = SKTexture(imageNamed: "board-space")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        if (color == Color.BLACK) {
            self.colorBlendFactor = 1.0
            self.color = SKColor.redColor()
        }
        self.zPosition = ZPOSITION_BOARD_SPACE
        addChild(highlight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func valid(){
        highlight.hidden = false
    }
    
    func invalid(){
        highlight.hidden = true
    }

}