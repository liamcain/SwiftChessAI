//
//  GamePiece.swift
//  ChessAI
//
//  Created by Zack Meath on 11/4/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation


func == (lhs: GamePiece, rhs: GamePiece) -> Bool {
    return lhs.kind == rhs.kind && lhs.side == rhs.side
}

class GamePiece: CustomStringConvertible, Equatable {
    
    var side: Side
    var kind: Kind
    var description: String {
        return "\(side)'s \(kind)"
    }
    
    init(side: Side, kind: Kind){
        self.side = side
        self.kind = kind
    }
    
    init(piece: GamePiece) {
        side = piece.side
        kind = piece.kind
    }
    
    init(str: String) {
        self.side = (str < "a") ? Side.WHITE : Side.BLACK
        
        switch str.lowercaseString {
            case "r":
                kind = Kind.ROOK
            case "b":
                kind = Kind.BISHOP
            case "k":
                kind = Kind.KING
            case "q":
                kind = Kind.QUEEN
            case "n":
                kind = Kind.KNIGHT
            default:
                kind = Kind.PAWN
        }
    }
    
    func getOffsetArray() -> [Int] {
        switch kind {
        case .PAWN:
            if self.side == Side.WHITE {
                return [-16, -32, -17, -15]
            } else {
                return [16, 32, 17, 15]
            }
        case .KNIGHT:
            return [-18, -33, -31, -14,  18, 33, 31,  14]
        case .BISHOP:
            return [-17, -15,  17,  15]
        case .ROOK:
            return [-16,   1,  16,  -1]
        case .QUEEN:
            return [-17, -16, -15,   1,  17, 16, 15,  -1]
        case .KING:
            return [-17, -16, -15,   1,  17, 16, 15,  -1]
        }
    }
    
    func getShift() -> Int {
        switch kind {
        case .PAWN:   return 0
        case .KNIGHT: return 1
        case .BISHOP: return 2
        case .ROOK:   return 3
        case .QUEEN:  return 4
        case .KING:   return 5
        }
    }
    
    
}