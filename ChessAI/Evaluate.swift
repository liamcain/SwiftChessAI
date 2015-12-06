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
    var move: GameMove?
    
    weak var parent: GameNode?
    var children: [GameNode]
    
    var material: Int?
    var kingSafety: Int?
    var centerControl: Int?
   
    init(game: Game, gameMove: GameMove?=nil) {
        self.game = game
        self.move = gameMove
        children = [GameNode]()
    }
    
    func add(game: Game, move: GameMove) -> GameNode {
        let node = GameNode(game: game, gameMove: move)
        node.parent = self
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
        root = GameNode(game: game.copy())
        leafQueue = Queue<GameNode>()
        leafQueue.enqueue(root)
    }
    
    func updateRoot(move: GameMove) {
        for c in root.children {
            if c.move == move {
                root = c
                return
            }
        }
    }
    
    func start() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            while true {
                self.evaluateFromQueue()
            }
        }
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
            return blackScore - whiteScore
        } else {
            return whiteScore - blackScore
        }
    }
    
    func evaluateNode(node: GameNode) {
        node.material = self.evaluateMaterial(node)
    }
    
    func evaluateFromQueue(){
        if let node = leafQueue.dequeue() {
            
            // Check if node is a descendant of the current board state.
            var ancestor: GameNode? = node
            while ancestor?.parent != nil {
                ancestor = ancestor?.parent
            }
            if ancestor !== root { return }
            
            let options = GameOptions()
            options.legal = false
            
            let moves = node.game.generateMoves(options)
            for m in moves {
                let child = node.game.copy()
                child.makeMove(m)
                if !child.kingAttacked(child.turn) {
                    let childNode = node.add(child, move: m)
                    evaluateNode(childNode)
                    leafQueue.enqueue(childNode)
                }
            }
        }
    }
    
    func search() -> GameMove {
        var bestMove = root.children[0]
        for c in root.children {
            if c.material > bestMove.material {
                bestMove = c
            }
        }
        root = bestMove
        return bestMove.move!
    }
}