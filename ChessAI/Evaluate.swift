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
    let PIECE_VALUES: [Kind:Int] = [
        Kind.PAWN   : 100,
        Kind.KNIGHT : 300,
        Kind.BISHOP : 300,
        Kind.ROOK   : 500,
        Kind.QUEEN  : 900,
        Kind.KING: 999999,
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
                if piece.side == Side.BLACK {
                    if piece.kind == Kind.BISHOP {
                        blackBishops += 1
                    }
                    blackScore += self.PIECE_VALUES[piece.kind]!
                } else {
                    if piece.kind == Kind.BISHOP {
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
        
        if node.game.turn == Side.BLACK {
            return (blackScore - whiteScore) / 100
        } else {
            return (whiteScore - blackScore) / 100
        }
    }
    
    func evaluateNode(node: GameNode) {
        node.material = self.evaluateMaterial(node)
        node.overallScore = node.material
    }
    
    func evaluateGamePST(game: Game) -> Int {
        var whiteScore = 0
        var blackScore = 0
        
        let board = game.board
        let first_sq = board.SQUARES["a8"]
        let last_sq = board.SQUARES["h1"]
        
        for var i = first_sq!; i <= last_sq!; i++ {
            if let piece = board.get(i) {
                let num = self.convertPSTToInt(i)
                switch piece.kind {
                case Kind.PAWN:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whitePawnPST[num]
                    } else {
                        blackScore += Evaluate.blackPawnPST[num]
                    }
                case Kind.KNIGHT:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whiteKnightPST[num]
                    } else {
                        blackScore += Evaluate.blackKnightPST[num]
                    }
                case Kind.BISHOP:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whiteBishopPST[num]
                    } else {
                        blackScore += Evaluate.blackBishopPST[num]
                    }
                case Kind.ROOK:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whiteRookPST[num]
                    } else {
                        blackScore += Evaluate.blackRookPST[num]
                    }
                case Kind.QUEEN:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whiteQueenPST[num]
                    } else {
                        blackScore += Evaluate.blackQueenPST[num]
                    }
                case Kind.KING:
                    if piece.side == Side.WHITE {
                        whiteScore += Evaluate.whiteKingPST[num]
                    } else {
                        blackScore += Evaluate.blackKingPST[num]
                    }
                }
            }
        }
        return whiteScore - blackScore
    }
    
    func evaluateGameMaterial(game: Game) -> Int {
        var whiteScore = 0
        var blackScore = 0
        var whiteBishops = 0
        var blackBishops = 0
        
        let board = game.board
        let first_sq = board.SQUARES["a8"]
        let last_sq = board.SQUARES["h1"]
        
        for var i = first_sq!; i <= last_sq!; i++ {
            if let piece = board.get(i) {
                if piece.side == Side.BLACK {
                    if piece.kind == .BISHOP {
                        blackBishops += 1
                    }
                    blackScore += self.PIECE_VALUES[piece.kind]!
                } else {
                    if piece.kind == .BISHOP {
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
        
        return (whiteScore - blackScore)
        
    }
    func evaluateGame(game: Game) -> Int {
        let material = self.evaluateGameMaterial(game)
        let pst = self.evaluateGamePST(game)
        return material + pst
    }
    
    
    func convertPSTToInt(num: Int) -> Int {
        return ((num / 16) / 8) + (num % 8) // No, you cant simplify to (num/2) because rounding
    }
    
    // Pawn piece-square table
    static let whitePawnPST = [
        0, 0, 0, 0, 0, 0, 0, 0,
        20, 20, 20, 30, 30, 20, 20, 20,
        10, 10, 20, 30, 30, 20, 10, 10,
        5, 5, 10, 25, 25, 10, 5, 5,
        0, 0, 0, 20, 20, 0, 0, 0,
        5, -5, -10, 0, 0, -10, -5, 5,
        5, 10, 10, -20, -20, 10, 10, 5,
        0, 0, 0, 0, 0, 0, 0, 0
    ]
    static let blackPawnPST = [
        0, 0, 0, 0, 0, 0, 0, 0,
        5, 10, 10, -20, -20, 10, 10, 5,
        5, -5, -10, 0, 0, -10, -5, 5,
        0, 0, 0, 20, 20, 0, 0, 0,
        5, 5, 10, 25, 25, 10, 5, 5,
        10, 10, 20, 30, 30, 20, 10, 10,
        20, 20, 20, 30, 30, 20, 20, 20,
        0, 0, 0, 0, 0, 0, 0, 0
    ]
    // Knight piece-square table
    static let whiteKnightPST = [
        -50, -40, -30, -30, -30, -30, -40, -50,
        -40, -20, 0, 0, 0, 0, -20, -40,
        -30, 0, 10, 15, 15, 10, 0, -30,
        -30, 5, 15, 20, 20, 15, 5, -30,
        -30, 0, 15, 20, 20, 15, 0, -30,
        -30, 5, 10, 15, 15, 10, 5, -30,
        -40, -20, 0, 5, 5, 0, -20, -40,
        -50, -40, -30, -30, -30, -30, -40, -50
    ]
    static let blackKnightPST = [
        -50, -40, -30, -30, -30, -30, -40, -50,
        -40, -20, 0, 5, 5, 0, -20, -40,
        -30, 5, 10, 15, 15, 10, 5, -30,
        -30, 0, 15, 20, 20, 15, 0, -30,
        -30, 5, 15, 20, 20, 15, 5, -30,
        -30, 0, 10, 15, 15, 10, 0, -30,
        -40, -20, 0, 0, 0, 0, -20, -40,
        -50, -40, -30, -30, -30, -30, -40, -50
    ]
    // Bishop piece-square table
    static let whiteBishopPST = [
        -20, -10, -10, -10, -10, -10, -10, -20,
        -10, 0, 0, 0, 0, 0, 0, -10,
        -10, 0, 5, 10, 10, 5, 0, -10,
        -10, 5, 5, 10, 10, 5, 5, -10,
        -10, 0, 10, 10, 10, 10, 0, -10,
        -10, 10, 10, 10, 10, 10, 10, -10,
        -10, 5, 0, 0, 0, 0, 5, -10,
        -20, -10, -10, -10, -10, -10, -10, -20
    ]
    static let blackBishopPST = [
        -20, -10, -10, -10, -10, -10, -10, -20,
        -10, 5, 0, 0, 0, 0, 5, -10,
        -10, 10, 10, 10, 10, 10, 10, -10,
        -10, 0, 10, 10, 10, 10, 0, -10,
        -10, 5, 5, 10, 10, 5, 5, -10,
        -10, 0, 5, 10, 10, 5, 0, -10,
        -10, 0, 0, 0, 0, 0, 0, -10,
        -20, -10, -10, -10, -10, -10, -10, -20,
    ]
    // Rook piece-square table
    static let whiteRookPST = [
        0, 0, 0, 0, 0, 0, 0, 0,
        5, 10, 10, 10, 10, 10, 10, 5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        0, 0, 0, 5, 5, 0, 0, 0
    ]
    static let blackRookPST = [
        0, 0, 0, 5, 5, 0, 0, 0,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        -5, 0, 0, 0, 0, 0, 0, -5,
        5, 10, 10, 10, 10, 10, 10, 5,
        0, 0, 0, 0, 0, 0, 0, 0
    ]
    // Queen piece-square tables
    static let whiteQueenPST = [
        -20, -10, -10, -5, -5, -10, -10, -20,
        -10, 0, 0, 0, 0, 0, 0, -10,
        -10, 0, 5, 5, 5, 5, 0, -10,
        -5, 0, 5, 5, 5, 5, 0, -5,
        0, 0, 5, 5, 5, 5, 0, -5,
        -10, 5, 5, 5, 5, 5, 0, -10,
        -10, 0, 5, 0, 0, 0, 0, -10,
        -20, -10, -10, -5, -5, -10, -10, -20
    ]
    static let blackQueenPST = [
        -20, -10, -10, -5, -5, -10, -10, -20,
        -10, 0, 5, 0, 0, 0, 0, -10,
        -10, 5, 5, 5, 5, 5, 0, -10,
        0, 0, 5, 5, 5, 5, 0, -5,
        -5, 0, 5, 5, 5, 5, 0, -5,
        -10, 0, 5, 5, 5, 5, 0, -10,
        -10, 0, 0, 0, 0, 0, 0, -10,
        -20, -10, -10, -5, -5, -10, -10, -20
    ]
    // King piece-square tables
    static let whiteKingPST = [
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -20, -30, -30, -40, -40, -30, -30, -20,
        -10, -20, -20, -20, -20, -20, -20, -10,
        20, 20, 0, 0, 0, 0, 20, 20,
        10, 10, 10, 0, 0, 10, 10, 10
    ]
    static let blackKingPST = [
        10, 10, 10, 0, 0, 10, 10, 10,
        20, 20, 0, 0, 0, 0, 20, 20,
        -10, -20, -20, -20, -20, -20, -20, -10,
        -20, -30, -30, -40, -40, -30, -30, -20,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30,
        -30, -40, -40, -50, -50, -40, -40, -30
    ]
}