//
//  Bishop.swift
//  ChessAI
//
//  Created by Liam Cain on 10/29/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Bishop: Piece {
    
    init(side: Piece.Side, space: (Int, Int)) {
        var colorName = "w"
        if side == Piece.Side.BLACK {
            colorName = "b"
        }
        let texture = SKTexture(imageNamed: colorName + "B")
        super.init(side: side, type: Type.BISHOP, space: space, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
