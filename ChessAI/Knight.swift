//
//  Knight.swift
//  ChessAI
//
//  Created by Liam Cain on 10/29/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Knight: Piece {
    
    init(side: Piece.Side, space: (Int, Int)) {
        var colorName = "w"
        if side == Piece.Side.BLACK {
            colorName = "b"
        }
        let texture = SKTexture(imageNamed: colorName + "N")
        super.init(side: side, type: Type.KNIGHT, space: space, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}