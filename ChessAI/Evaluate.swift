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
        .PAWN   : 100,
        .KNIGHT : 300,
        .BISHOP : 300,
        .ROOK   : 500,
        .QUEEN  : 900,
        .KING   : 0,
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
    
    func evaluatePiecePST(piece: GamePiece, num: Int) -> Int {
        if piece.side == Side.WHITE {
            switch piece.kind {
            case Kind.PAWN:
                return Evaluate.whitePawnPST[num]
            case Kind.KNIGHT:
                return Evaluate.whiteKnightPST[num]
            case Kind.BISHOP:
                return Evaluate.whiteBishopPST[num]
            case Kind.ROOK:
                return Evaluate.whiteRookPST[num]
            case Kind.QUEEN:
                return Evaluate.whiteQueenPST[num]
            case Kind.KING:
                return Evaluate.whiteKingPST[num]
            }
        } else {
            switch piece.kind {
            case Kind.PAWN:
                return Evaluate.blackPawnPST[num]
            case Kind.KNIGHT:
                return Evaluate.blackKnightPST[num]
            case Kind.BISHOP:
                return Evaluate.blackBishopPST[num]
            case Kind.ROOK:
                return Evaluate.blackRookPST[num]
            case Kind.QUEEN:
                return Evaluate.blackQueenPST[num]
            case Kind.KING:
                return Evaluate.blackKingPST[num]
            }
        }
    }
    
    
    func evaluateGame(game: Game) -> Int {
        
        // Score array layout:
        // 0: Material sum
        // 1: Piece-square tables (PST) sum
        // 2: Number of bishops (to calculate bishop pair)
        // 3: Mobility Score
        var whiteScore: [Int] = [0,0,0,0]
        var blackScore: [Int] = [0,0,0,0]
        
        let board = game.board
        
        
        if game.inCheckmate() {
            if game.turn == .WHITE {
                return -INFINITY
            } else {
                return INFINITY
            }
        }
        
        // Loop through all of the pieces on the board
        for var i = 0; i <= 119; i++ {
            if (i & 0x88 > 0) {
                i += 7
                continue
            }
            if let piece = board.get(i) {
                if piece.side == Side.WHITE {
                    whiteScore[0] += self.PIECE_VALUES[piece.kind]! // Material
                    whiteScore[1] += self.evaluatePiecePST(piece, num: self.convertBoardToPST(i)) // PST
                    if piece.kind == .BISHOP {
                        whiteScore[2] += 1
                    }
                } else {
                    blackScore[0] += self.PIECE_VALUES[piece.kind]! // Material
                    blackScore[1] += self.evaluatePiecePST(piece, num: self.convertBoardToPST(i)) // PST
                    if piece.kind == .BISHOP {
                        blackScore[2] += 1
                    }
                }
            }
        }
        
        
        // Add weight to PST
        whiteScore[1] *= PST_WEIGHT
        blackScore[1] *= PST_WEIGHT
        
        // Award points for having both bishops
        whiteScore[2] = whiteScore[2] >= 2 ? BISHOP_PAIR_VALUE : 0
        blackScore[2] = blackScore[2] >= 2 ? BISHOP_PAIR_VALUE : 0
        
//         Account for mobility
        let options = GameOptions()
        options.legal = false
        if game.turn == .WHITE {
            whiteScore[3] = game.generateMoves(options).count * MOBILITY_WEIGHT
            game.turn = .BLACK
            blackScore[3] = game.generateMoves(options).count * MOBILITY_WEIGHT
            game.turn = .WHITE
        } else {
            blackScore[3] = game.generateMoves(options).count * MOBILITY_WEIGHT
            game.turn = .WHITE
            whiteScore[3] = game.generateMoves(options).count * MOBILITY_WEIGHT
            game.turn = .BLACK
        }
        
        
        // Take the array and calculate the final score
        let whiteFinalScore = whiteScore.reduce(0, combine: +)
        let blackFinalScore = blackScore.reduce(0, combine: +)
        
        // Return the final scores
        return whiteFinalScore - blackFinalScore
    }
    
    func convertBoardToPST(num: Int) -> Int {
        return ((num / 16) * 8) + (num % 8) // No, you cant simplify to (num/2) because rounding
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