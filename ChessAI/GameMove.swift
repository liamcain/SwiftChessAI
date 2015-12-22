//
//  GameMove.swift
//  ChessAI
//
//  Created by Zack Meath on 11/4/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation


func == (lhs: GameMove, rhs: GameMove) -> Bool {
    return lhs.fromIndex == rhs.fromIndex && lhs.toIndex == rhs.toIndex
}

class GameMove: Equatable {
    
    enum Flag: Int {
        case NORMAL
        case PAWN_PUSH
        case PAWN_PROMOTION
        case PAWN_PROMOTION_CAPTURE
        case EN_PASSANT
        case CAPTURE
        case KINGSIDE_CASTLE
        case QUEENSIDE_CASTLE
    }
    
    var side: Side
    var epSquare: Int = -1
    var halfMoves: Int = 0
    var moveNumber: Int = 1
    
    var bKing: Int             =    4
    var bKingsideCastle:  Bool = true
    var bQueensideCastle: Bool = true
    var wKing: Int             =  116
    var wKingsideCastle:  Bool = true
    var wQueensideCastle: Bool = true
    
    var fromIndex: Int
    var toIndex: Int
    var flag: Flag
    var promotionPiece: Kind?
    var capturedPiece: GamePiece?
    
    init (side: Side, fromIndex: Int, toIndex: Int, flag: Flag, promotionPiece: Kind?, capturedPiece: GamePiece?){
        self.side = side
        self.fromIndex = fromIndex
        self.toIndex = toIndex
        self.flag = flag
        self.promotionPiece = promotionPiece
        self.capturedPiece = capturedPiece
    }
}