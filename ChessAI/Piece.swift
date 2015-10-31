//
//  Piece.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Piece: SKSpriteNode {
   
    var side: Side
    var type: Type
    
    enum Type {
        case KING
        case QUEEN
        case ROOK
        case KNIGHT
        case BISHOP
        case PAWN
    }
    
    enum Side {
        case WHITE
        case BLACK
    }
    
    init(side: Side, type: Type, texture: SKTexture) {
        self.side = side
        self.type = type
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.zPosition = ZPOSITION_INACTIVE_PIECE
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
