//
//  Constants.swift
//  ChessAI
//
//  Created by Liam Cain on 10/27/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

let MAX_SEARCH_DEPTH = 3

let SPACE_WIDTH = CGFloat(100)
let HALF_SPACE_WIDTH = CGFloat(50)
let FULL_BOARD_WIDTH = CGFloat(800)

let ZPOSITION_ACTIVE_PIECE = CGFloat(100)
let ZPOSITION_INACTIVE_PIECE = CGFloat(2)
let ZPOSITION_BOARD_HIGHLIGHT = CGFloat(2)
let ZPOSITION_BOARD_SPACE = CGFloat(0)

let BOARD_BLACK = SKColor(red: 0, green: 0.6, blue: 0.83, alpha: 1.0)
let BOARD_BLACK_HIGHLIGHT = SKColor(red: 0, green: 0.46, blue: 0.68, alpha: 1.0)
let BOARD_WHITE = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let BOARD_WHITE_HIGHLIGHT = SKColor(red: 0.86, green: 0.92, blue: 1.0, alpha: 1.0)

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