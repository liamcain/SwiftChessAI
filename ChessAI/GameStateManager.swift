//
//  GameStateManager.swift
//  ChessAI
//
//  Created by Liam Cain on 12/5/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Cocoa

class GameStateManager {
    
    static let sharedInstance = GameStateManager()
    
    var fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    var moveNumber: Int = 0
    var turn: Side = .WHITE
    
//    init() {
//        fen =
//        moveNumber = 0
//        turn = GamePiece.Side.WHITE
//    }
    
    func log(str: String) {
        
    }
}