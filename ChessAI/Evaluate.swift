//
//  Evaluate.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class GameNode {
    
    var game: Game
    var children: [GameNode]
    
    var material: Int?
    var kingSafety: Int?
    var centerControl: Int?
    
    init(game: Game) {
        self.game = game
        children = [GameNode]()
    }
    
    func add(game: Game) -> GameNode {
        let node = GameNode(game: game)
        children.append(node)
        return node
    }
}


class Evaluate {
    
    var root: GameNode
    var leafQueue: Queue<GameNode>
    
    // Claude Shannon(1949) values
    let PIECE_VALUES: [GamePiece.Kind:Int] = [
        GamePiece.Kind.PAWN   : 100,
        GamePiece.Kind.KNIGHT : 300,
        GamePiece.Kind.BISHOP : 300,
        GamePiece.Kind.ROOK   : 500,
        GamePiece.Kind.QUEEN  : 900,
        GamePiece.Kind.KING: 999999,
    ];
    
    // Larry Kaufman(2012) values
    // let PIECE_VALUES: [GamePiece.Kind:Int] = [
    //     GamePiece.Kind.PAWN   : 100,
    //     GamePiece.Kind.KNIGHT : 350,
    //     GamePiece.Kind.BISHOP : 350,
    //     GamePiece.Kind.ROOK   : 525,
    //     GamePiece.Kind.QUEEN  : 1000,
    //     GamePiece.Kind.KING   : 999999,
    // ];
    
    init(game: Game) {
        root = GameNode(game: game)
        leafQueue = Queue<GameNode>()
        leafQueue.enqueue(root)
        evaluateFromQueue()
    }
    
    func start() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            repeat {
                self.evaluateFromQueue()
            } while (true)
        }
    }
    
    func evaluateMaterial(node: GameNode) -> Int {
        var whiteScore = 0
        var blackScore = 0
        var whiteBishops = 0
        var blackBishops = 0
        
        let game = node.game
        let board = game.board
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
        return whiteScore - blackScore
    }
    
    func evaluateNode(node: GameNode) -> Int{
        let material = self.evaluateMaterial(node)
        return material;
    }
    
    func evaluateFromQueue(){
//        print("Queue Size: \(leafQueue.count)")
        if let node = leafQueue.dequeue() {
            let options = GameOptions()
            options.legal = false
            
            let moves = node.game.generateMoves(options)
            for m in moves {
                let child = node.game.copy()
                child.makeMove(m)
                if !child.kingAttacked(child.turn) {
                    let childNode = node.add(child)
                    evaluateNode(childNode)
                    leafQueue.enqueue(childNode)
                }
            }
        }
    }
}