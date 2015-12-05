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
    let search: Search
    
    init(startState: String) {
        let game = Game()
        game.loadFromFen(startState)
        eval = Evaluate(game: game)
        search = Search(root: eval.root)
    }
    
}