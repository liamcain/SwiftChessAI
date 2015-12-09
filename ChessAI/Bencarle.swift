//
//  Bencarle.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class Bencarle {
    
    var search: Search
    var nextMove: GameMove?
    
    init(boardState: Game) {
        search = Search(game: boardState)
    }
    
    func handleMove(move: GameMove?) {
        if move != nil {
            search.updateRoot(move!)
        }
        let timeForTurn = calculateTimeForTurn()
        delay(timeForTurn) {
            self.nextMove = self.search.search()
        }
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