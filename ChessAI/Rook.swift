//
//  Rook.swift
//  ChessAI
//
//  Created by Liam Cain on 10/29/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Rook: Piece {
    
    init(side: Piece.Side, space: (Int, Int)) {
        var colorName = "w"
        if side == Piece.Side.BLACK {
            colorName = "b"
        }
        let texture = SKTexture(imageNamed: colorName + "R")
        super.init(side: side, type: Type.ROOK, space: space, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}