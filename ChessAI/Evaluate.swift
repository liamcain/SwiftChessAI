//
//  Evaluate.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation




class Evaluate {
    
    // Claude Shannon(1949) values
    let PIECE_VALUES: [GamePiece.Kind:Int] = [
        GamePiece.Kind.PAWN   : 100,
        GamePiece.Kind.KNIGHT : 300,
        GamePiece.Kind.BISHOP : 300,
        GamePiece.Kind.ROOK   : 500,
        GamePiece.Kind.QUEEN  : 900,
        GamePiece.Kind.KING: 999999,
    ]
    
    // Larry Kaufman(2012) values
    // let PIECE_VALUES: [GamePiece.Kind:Int] = [
    //     GamePiece.Kind.PAWN   : 100,
    //     GamePiece.Kind.KNIGHT : 350,
    //     GamePiece.Kind.BISHOP : 350,
    //     GamePiece.Kind.ROOK   : 525,
    //     GamePiece.Kind.QUEEN  : 1000,
    //     GamePiece.Kind.KING   : 999999,
    // ]
    
    init (){
    }
    
    
    func evaluateMaterial(node: GameNode) -> Int {
        var whiteScore = 0
        var blackScore = 0
        var whiteBishops = 0
        var blackBishops = 0
        
        let board = node.game.board
        let first_sq = board.SQUARES["a8"]
        let last_sq = board.SQUARES["h1"]
        
        for var i = first_sq!; i <= last_sq!; i++ {
            if let piece = board.get(i) {
                if piece.side == GamePiece.Side.BLACK {
                    if piece.kind == GamePiece.Kind.BISHOP {
                        blackBishops += 1
                    }
                    blackScore += self.PIECE_VALUES[piece.kind]!
                } else {
                    if piece.kind == GamePiece.Kind.BISHOP {
                        whiteBishops += 1
                    }
                    whiteScore += self.PIECE_VALUES[piece.kind]!
                }
            }
            if i % 8 == 7 { i += 8 }
        }
        if whiteBishops == 2 {
            whiteScore += 50
        }
        if blackBishops == 2 {
            blackScore += 50
        }
        
        if node.game.turn == GamePiece.Side.BLACK {
            return (blackScore - whiteScore) / 100
        } else {
            return (whiteScore - blackScore) / 100
        }
    }
    
    func evaluateNode(node: GameNode) {
        node.material = self.evaluateMaterial(node)
        node.overallScore = node.material
    }
    
    
    
//    func search() -> GameMove {
//         var bestMove: GameNode? = nil
//         var bestScore: Int = -1
//         for c in root.children {
//             var bestOpponentMove: GameNode? = nil
//             var bestOpponentScore: Int = -1
//             for cc in c.children {
//                 if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.BLACK && cc.overallScore > bestOpponentMove!.overallScore) {
//                     bestOpponentMove = cc
//                     bestOpponentScore = bestOpponentMove!.overallScore!
//                 } else if bestOpponentMove == nil || (cc.game.turn == GamePiece.Side.WHITE && cc.overallScore < bestOpponentMove!.overallScore) {
//                     bestOpponentMove = cc
//                     bestOpponentScore = bestOpponentMove!.overallScore!
//                 }
//             }
//             
//             if bestMove == nil || (c.game.turn == GamePiece.Side.BLACK && c.overallScore! - bestOpponentScore > bestScore) {
//                 bestMove = c
//                 bestScore = bestMove!.overallScore! - bestOpponentScore
//             } else if bestMove == nil || (c.game.turn == GamePiece.Side.WHITE && c.overallScore! - bestOpponentScore < bestScore) {
//                 bestMove = c
//                 bestScore = bestMove!.overallScore! - bestOpponentScore
//             }
//         }
//         root = bestMove!
//         return bestMove!.move!
//     }
}