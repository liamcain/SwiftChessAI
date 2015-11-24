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
    
    init(startState: Game) {
        eval = Evaluate(game: startState)
        search = Search(root: eval.root)
        
        eval.start()
    }
    
}