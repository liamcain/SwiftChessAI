//
//  Bencarle.swift
//  ChessAI
//
//  Created by Liam Cain on 11/23/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

class Bencarle {
    
    let eval: Evaluate
    var nextMove: GameMove?
//    let search: Search
    
    init(boardState: Game) {
        eval = Evaluate(game: boardState)
        eval.start()
    }
    
    func handleMove(fen: String) {
        eval.updateRoot(fen)
        let timeForTurn = calculateTimeForTurn()
       
        delay(timeForTurn) {
            self.nextMove = self.eval.search()
        }
    }
    
    func calculateTimeForTurn() -> Double {
        return 3.0
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