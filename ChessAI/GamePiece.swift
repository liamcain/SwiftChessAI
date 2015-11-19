//
//  GamePiece.swift
//  ChessAI
//
//  Created by Zack Meath on 11/4/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class GamePiece: CustomStringConvertible {
    
    enum Kind: String {
        case KING = "k"
        case QUEEN = "q"
        case ROOK = "r"
        case KNIGHT = "n"
        case BISHOP = "b"
        case PAWN = "p"
    }
    
    enum Side {
        case WHITE
        case BLACK
    }
    
    var side: Side
    var kind: Kind
    var description: String {
        return "\(side)'s \(kind)"
    }
    
    init(side: Side, kind: Kind){
        self.side = side
        self.kind = kind
    }
    
    init(str: String) {
        self.side = (str < "a") ? GamePiece.Side.WHITE : GamePiece.Side.BLACK
        
        switch str.lowercaseString {
            case "r":
                self.kind = GamePiece.Kind.ROOK
            case "b":
                self.kind = GamePiece.Kind.BISHOP
            case "k":
                self.kind = GamePiece.Kind.KING
            case "q":
                self.kind = GamePiece.Kind.QUEEN
            case "n":
                self.kind = GamePiece.Kind.KNIGHT
            default:
                self.kind = GamePiece.Kind.PAWN
        }
    }
    
    func getOffsetArray() -> [Int]{
        switch self.kind {
        case Kind.PAWN:
            if self.side == Side.WHITE {
                return [-16, -32, -17, -15]
            } else {
                return [16, 32, 17, 15]
            }
        case Kind.KNIGHT:
            return [-18, -33, -31, -14,  18, 33, 31,  14]
        case Kind.BISHOP:
            return [-17, -15,  17,  15]
        case Kind.ROOK:
            return [-16,   1,  16,  -1]
        case Kind.QUEEN:
            return [-17, -16, -15,   1,  17, 16, 15,  -1]
        case Kind.KING:
            return [-17, -16, -15,   1,  17, 16, 15,  -1]
        }
    }
    
    
}