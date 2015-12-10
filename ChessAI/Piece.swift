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
    var boardSpace: (Int, Int)
    
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
    
    init(side: Side, type: Type, space: (Int, Int)) {
        self.side = side
        self.type = type
        self.boardSpace = space
        
        var typeName = "p"
        switch type {
            case .KING:   typeName = "k"
            case .QUEEN:  typeName   = "q"
            case .ROOK:   typeName = "r"
            case .KNIGHT: typeName = "k"
            case .BISHOP: typeName = "b"
            case .PAWN:   typeName = "p"
        }
        var color = "w"
        if side == Side.BLACK { color = "b" }
        let texture = SKTexture(imageNamed: color + typeName + ".png")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.zPosition = ZPOSITION_INACTIVE_PIECE
    }
    
    func setType(type: Type) -> SKTexture {
        var typeName = "p"
        switch type {
            case .KING:   typeName = "k"
            case .QUEEN:  typeName   = "q"
            case .ROOK:   typeName = "r"
            case .KNIGHT: typeName = "k"
            case .BISHOP: typeName = "b"
            case .PAWN:   typeName = "p"
        }
        var color = "w"
        if side == Side.BLACK { color = "b" }
        self.type = type
        let texture = SKTexture(imageNamed: color + typeName + ".png")
        self.texture = texture
        return texture
    }
    
    func setSpace(x: Int, y: Int) {
        position = CGPoint(x: CGFloat(x) * SPACE_WIDTH + HALF_SPACE_WIDTH,
                           y: CGFloat(y) * SPACE_WIDTH + HALF_SPACE_WIDTH)
        boardSpace = (x, y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boardIndex() -> Int {
        return (7 - boardSpace.1) * 16 + boardSpace.0
    }
}
