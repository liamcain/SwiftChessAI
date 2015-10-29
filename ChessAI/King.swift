//
//  King.swift
//  ChessAI
//
//  Created by Liam Cain on 10/29/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class King: Piece {
    
    init(side: Piece.Side) {
        var colorName = "w"
        if side == Piece.Side.BLACK {
            colorName = "b"
        }
        let texture = SKTexture(imageNamed: colorName + "K")
        super.init(side: side, type: Type.PAWN, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
