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
    var kind: Kind
    var boardSpace: (Int, Int)
    
//    enum Type {
//        case KING
//        case QUEEN
//        case ROOK
//        case KNIGHT
//        case BISHOP
//        case PAWN
//    }
//    
//    enum Side {
//        case WHITE
//        case BLACK
//    }
    
    init(side: Side, kind: Kind, space: (Int, Int)) {
        self.side = side
        self.kind = kind
        self.boardSpace = space
        
        var typeName = "p"
        switch kind {
            case .KING:   typeName = "K"
            case .QUEEN:  typeName = "Q"
            case .ROOK:   typeName = "R"
            case .KNIGHT: typeName = "N"
            case .BISHOP: typeName = "B"
            case .PAWN:   typeName = "P"
        }
        let color = side == .BLACK ?"b" :"w"
        let texture = SKTexture(imageNamed: color + typeName)
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        self.zPosition = ZPOSITION_INACTIVE_PIECE
    }
    
    func getValue() -> Int {
        switch kind {
            case .KING:   return 120
            case .QUEEN:  return 80
            case .ROOK:   return 40
            case .KNIGHT: return 25
            case .BISHOP: return 25
            case .PAWN:   return 15
        }
        
    }
    
    func setKind(kind: Kind) -> SKTexture {
        var typeName = "P"
        switch kind {
            case .KING:   typeName = "K"
            case .QUEEN:  typeName = "Q"
            case .ROOK:   typeName = "R"
            case .KNIGHT: typeName = "N"
            case .BISHOP: typeName = "B"
            case .PAWN:   typeName = "P"
        }
        let color = side == .BLACK ?"b" :"w"
        self.kind = kind
        let texture = SKTexture(imageNamed: color + typeName)
        self.texture = texture
        return texture
    }
    
    func setSpace(x: Int, y: Int) {
        
        let position = CGPoint(x: CGFloat(x) * SPACE_WIDTH + HALF_SPACE_WIDTH,
                           y: CGFloat(y) * SPACE_WIDTH + HALF_SPACE_WIDTH)
        runAction(SKAction.moveTo(position, duration: 0.2))
        boardSpace = (x, y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boardIndex() -> Int {
        return (7 - boardSpace.1) * 16 + boardSpace.0
    }
}
