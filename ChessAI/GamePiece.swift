//
//  GamePiece.swift
//  ChessAI
//
//  Created by Zack Meath on 11/4/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class GamePiece {
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
    
    var side: Side
    var type: Type
    
    init(side: Side, type: Type){
        self.side = side
        self.type = type
    }
    
    func getOffsetArray() -> [Int]{
        switch self.type {
            case Type.PAWN:
                if self.side == Side.WHITE {
                    return [-16, -32, -17, -15]
                } else {
                    return [16, 32, 17, 15]
                }
            case Type.KNIGHT:
                return [-18, -33, -31, -14,  18, 33, 31,  14]
            case Type.BISHOP:
                return [-17, -15,  17,  15]
            case Type.ROOK:
                return [-16,   1,  16,  -1]
            case Type.QUEEN:
                return [-17, -16, -15,   1,  17, 16, 15,  -1]
            case Type.KING:
                return [-17, -16, -15,   1,  17, 16, 15,  -1]
            }
    }
}