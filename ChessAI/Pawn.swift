//
//  Pawn.swift
//  ChessAI
//
//  Created by Liam Cain on 10/27/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Pawn: Piece {
   
    init(side: Piece.Side, space: (Int, Int)) {
        var colorName = "w"
        if side == Piece.Side.BLACK {
            colorName = "b"
        }
        let texture = SKTexture(imageNamed: colorName + "P")
        super.init(side: side, type: Type.PAWN, space: space, texture: texture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}