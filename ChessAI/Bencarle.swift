//
//  Bencarle.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class Bencarle {
    
    // var search: Search
    var search: SingleThreadedSearch
    var nextMove: GameMove?
    var side: Side
    
    init(boardState: Game, side: Side) {
        self.side = side
        //search = Search(game: boardState, side: side)
        //search.start()
        search = SingleThreadedSearch(game: boardState, side: side)
    }
    
    func handleMove(move: GameMove?) {
        if move != nil {
            search.updateCurrentNode(move!)
        }
//        let timeForTurn = calculateTimeForTurn()
        
        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.search.alphaBetaSearch(self.search.game.copy(), depth: MAX_SEARCH_DEPTH, alpha: -999999, beta: 999999)
            // self.search.alphaBetaSearch(self.search.root, depth: 3, alpha: -999999, beta: 999999)
            self.nextMove = self.search.getBestMove()
        }
        
//        delay(timeForTurn) {
//            self.search.alphaBetaSearch(self.search.root, depth: 3, alpha: -999999, beta: 999999)
//            self.nextMove = self.search.getBestMove()
//        }
    }
    
    func calculateTimeForTurn() -> Double {
        return 0.3
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
}