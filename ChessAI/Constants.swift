//
//  Constants.swift
//  ChessAI
//
//  Created by Liam Cain on 10/27/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import Foundation

let SPACE_WIDTH = CGFloat(100)
let HALF_SPACE_WIDTH = CGFloat(50)
let FULL_BOARD_WIDTH = CGFloat(800)

let ZPOSITION_ACTIVE_PIECE = CGFloat(100)
let ZPOSITION_INACTIVE_PIECE = CGFloat(2)
let ZPOSITION_BOARD_HIGHLIGHT = CGFloat(2)
let ZPOSITION_BOARD_SPACE = CGFloat(0)

enum Kind {
    case KING
    case QUEEN
    case ROOK
    case KNIGHT
    case BISHOP
    case PAWN
}

enum Side {
    case BLACK
    case WHITE
}