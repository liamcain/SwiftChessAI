import Foundation

class Game {
    
    
    let EMPTY = -1
    
    var board = GameBoard()
    
    var kings = ["w": -1, "b": -1]
    var turn = GamePiece.Side.WHITE
    var castling = ["w": 0, "b": 0]
    var ep_square = -1
    var half_moves = 0
    var move_number = 1
    var history = []
    var header = {}
    
    let DEFAULT_POSITION = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    enum BITS: Int {
        case NORMAL = 1
        case CAPTURE = 2
        case BIG_PAWN = 4
        case EP_CAPTURE = 8
        case PROMOTION = 16
        case KSIDE_CASTLE = 32
        case QSIDE_CASTLE = 64
    }
    
    
    
    let RANK_1 = 7
    let RANK_2 = 6
    let RANK_3 = 5
    let RANK_4 = 4
    let RANK_5 = 3
    let RANK_6 = 2
    let RANK_7 = 1
    let RANK_8 = 0
    
    func clear() {
        board = GameBoard()
        kings = ["w": EMPTY, "b": EMPTY]
        turn = GamePiece.Side.WHITE
        castling = ["w": 0, "b": 0]
        ep_square = EMPTY
        half_moves = 0
        move_number = 1
        history = []
        //        header = []
        update_setup(generate_fen())
    }
    
    func reset() {
        loadFromFen(DEFAULT_POSITION)
    }
    
    func endTurn() {
        turn = (turn == GamePiece.Side.WHITE) ? GamePiece.Side.BLACK : GamePiece.Side.WHITE
    }
    
    func loadFromFen(fen: String) -> Bool {
        let tokens = fen.componentsSeparatedByString(" ")
        var position = Array(arrayLiteral: tokens[0])
        var square = 0
        
        //        if !validate_fen(fen).valid {
        //            return false
        //        }
        
        clear()
        
        for var i = 0; i < position.count; i++ {
            let piece = position[i]
            
            if piece == "/" {
                square += 8
            } else if let pieceValue = Int(piece) {
                square += pieceValue
            } else {
//                let color = (piece < "a") ? GamePiece.Side.WHITE : GamePiece.Side.BLACK
//                put(["type": piece.toLowerCase(), "color": color], algebraic(square))
                square++
            }
        }
        
        turn = tokens[1] == "w" ? GamePiece.Side.WHITE : GamePiece.Side.BLACK

        
        if tokens[2].rangeOfString("K") != nil {
            castling["b"]! |= BITS.KSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("Q") != nil {
            castling["w"]! |= BITS.QSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("k") != nil {
            castling["b"]! |= BITS.KSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("q") != nil {
            castling["b"]! |= BITS.QSIDE_CASTLE.rawValue
        }
        
        if tokens[3] == "-" {
            ep_square = EMPTY
        } else {
            ep_square = board.SQUARES[tokens[3]]!
        }
        half_moves = Int(tokens[4])!
        move_number = Int(tokens[5])!
        
        update_setup(generate_fen())
        
        return true
    }
    
    
    
    func update_setup(fen: String) {
        if history.count > 0 {
            return
        }
        
        //        if fen != DEFAULT_POSITION {
        //            header["SetUp"] = "1"
        //            header["FEN"] = fen
        //        } else {
        //            delete header["SetUp"]
        //            delete header["FEN"]
        //        }
    }
    
    func build_move(from: Int, to: Int, promotionPiece: GamePiece) -> GameMove {
        var flag = GameMove.Flag.NORMAL
        let movingPiece = board[from]
        let capturedPiece = board[to]
        
        if (capturedPiece != nil){ // Handle capturing pieces
            if movingPiece.type == GamePiece.Type.PAWN {
                if rank(to) == 1 || rank(to) == 8 {
                    // Pawn captured and needs to be promoted
                    flag = GameMove.Flag.PAWN_PROMOTION_CAPTURE
                } else {
                    // Pawn only captures
                    flag = GameMove.Flag.CAPTURE
                }
            } else {
                flag = GameMove.Flag.CAPTURE
            }
        } else if movingPiece.type = GamePiece.Type.KING { // Handle castling
            if file(from) == 5 && file(to) == 6 && board.canCastleKingside(turn){
                flag = GameMove.Flag.KINGSIDE_CASTLE
            } else if file(from) == 5 && file(to) == 3 && board.canCastleQueenside(turn) {
                flag = GameMove.Flag.QUEENSIDE_CASTLE
            } else {
                flag = GameMove.Flag.NORMAL
            }
        } else if movingPiece.type = GamePiece.Type.PAWN { // Handle PAWN_PROMOTION, PAWN_PUSH, and EN_PASSANT
            if rank(to) == 1 || rank(to) == 8 {
                flag = GameMove.Flag.PAWN_PROMOTION
            } else if rank(to) == rank(from) + 2 || rank(to) == rank(from) - 2 {
                flag = GameMove.Flag.PAWN_PUSH
            } else if file(to) != file(from) {
                flag = GameMove.Flag.EN_PASSANT
            }
        }
        var move = GameMove(side: turn, fromIndex: from, toIndex: to, flag: flag, promotionPiece: promotionPiece, capturedPiece: capturedPiece)
        return move
    }
    
    func rank(i: Int) -> Int {
        return i >> 4
    }
    
    func file(i: Int) -> Int {
        return i & 15
    }
    
    func algebraic(i: Int) -> String {
        let f = file(i), r = rank(i)
        return "abcdefgh".substringWithRange(NSRange(location: f, length: 1)) + "87654321".substringWithRange(NSRange(location: r, length: 1))
    }
    
    func swap_color(c: GamePiece.Side) -> GamePiece.Side {
        return c == GamePiece.Side.WHITE ? GamePiece.Side.BLACK : GamePiece.Side.WHITE
    }
    
    func generate_moves(options: GameOptions) -> Array<Int> {
        func add_move(board: GameBoard, moves: Array<Int>, from: Int, to: Int, flags: Int) {
            /* if pawn promotion */
//            if board[from]!.type == GamePiece.Type.PAWN && (rank(to) == RANK_8 || rank(to) == RANK_1) {
//                    let pieces = [GamePiece.Type.QUEEN, GamePiece.Type.ROOK, GamePiece.Type.BISHOP, GamePiece.Type.KNIGHT]
//                    for var i = 0; len = pieces.length; i < len; i++ {
//                        moves.push(build_move(board, from, to, flags, pieces[i]));
//                    }
//            } else {
//                moves.add(build_move(board, from, to, flags))
//            }
        }
        
        let moves = []
        let us = turn
        let them = swap_color(us)
        let second_rank = ["b": RANK_7, "w": RANK_2]
        
        var first_sq = board.SQUARES["a8"]
        var last_sq = board.SQUARES["h1"]
        var single_square = false
        
        /* do we want legal moves? */
        var legal = true
        if options.legal != nil {
            legal = options.legal!
        }
        
        /* are we generating moves for a single square? */
        if options.legal != nil {
            if options.square != nil {
                first_sq = board.SQUARES[options.square!]!
                last_sq = board.SQUARES[options.square!]!
                single_square = true
            } else {
                /* invalid square */
                return []
            }
        }
        
        for var i = first_sq!; i <= last_sq!; i++ {
            /* did we run off the end of the board */
            if i & 0x88 > 0 {
                i += 7
                continue
            }
            
            let piece: GamePiece = board[i]
            let offsetArray = piece.getOffsetArray();
            if piece.side != us {
                continue
            }
            
            
            if piece.type == GamePiece.Type.PAWN {
                /* single square, non-capturing */
                let square = i + offsetArray[us][0]
                
                if (board[square] == nil) {
                    add_move(board, moves, i, square, BITS.NORMAL)
                    
                    /* double square */
                    let square = i + offsetArray[1]
                    if (second_rank[us] == rank(i) && board[square] == nil) {
                        add_move(board, moves, i, square, BITS.BIG_PAWN)
                    }
                }
                
                /* pawn captures */
                for var j = 2; j < 4; j++ {
                    let square = i + offsetArray[j]
                    if square & 0x88 > 0 {
                        continue
                    }
                    
                    if board[square] != nil && board[square].color == them {
                        add_move(board, moves, i, square, BITS.CAPTURE)
                    } else if square == ep_square {
                        add_move(board, moves, i, ep_square, BITS.EP_CAPTURE)
                    }
                }
            } else {
                for var j = 0, len = offsetArray.count; j < len; j++ {
                    let offset = offsetArray[j]
                    var square = i
                    
                    while (true) {
                        square += offset
                        if square & 0x88 > 0 {
                            break
                        }
                        if (board[square] == nil) {
                            add_move(board, moves, i, square, BITS.NORMAL)
                        } else {
                            if (board[square].color == us) {
                                break
                            }
                            add_move(board, moves, i, square, BITS.CAPTURE)
                            break
                        }
                        
                        /* break, if knight or king */
                        if (piece.type == GamePiece.Type.KNIGHT || piece.type == GamePiece.Type.KING) {
                            break
                        }
                    }
                }
            }
        }
        
        /* check for castling if: a) we're generating all moves, or b) we're doing
        * single square move generation on the king's square
        */
        if !single_square || last_sq == kings[us] {
            /* king-side castling */
            if castling[us]! & BITS.KSIDE_CASTLE.rawValue > 0 {
                let castling_from = kings[us]
                let castling_to = castling_from! + 2
                
                if (board[castling_from + 1] == nil && board[castling_to] == nil && !attacked(them, kings[us]) && !attacked(them, castling_from + 1) && !attacked(them, castling_to)) {
                    add_move(board, moves: moves as! Array<Int>, from: kings[us]! , to: castling_to, flags: BITS.KSIDE_CASTLE.rawValue)
                }
            }
            
            /* queen-side castling */
            if (castling[us]! & BITS.QSIDE_CASTLE.rawValue) {
                let castling_from = kings[us]
                let castling_to = castling_from! - 2
                
                if (board[castling_from - 1] == nil && board[castling_from - 2] == nil && board[castling_from - 3] == nil && !attacked(them, kings[us]) && !attacked(them, castling_from - 1) && !attacked(them, castling_to)) {
                    add_move(board, moves: moves as! Array<Int>, from: kings[us]!, to: castling_to, flags: BITS.QSIDE_CASTLE.rawValue)
                }
            }
        }
        
        /* return all pseudo-legal moves (this includes moves that allow the king
        * to be captured)
        */
        if (!legal) {
            return moves as! Array<Int>
        }
        
        /* filter out illegal moves */
        let legal_moves = []
        for var i = 0, len = moves.count; i < len; i++ {
            make_move(moves[i])
            if !king_attacked(us) {
                legal_moves.push(moves[i])
            }
            undo_move()
        }
        
        return legal_moves as! Array<Int>
    }
    
    
    
    func generate_fen() -> String {
        var empty = 0
        var fen = ""
        
        for var i = board.SQUARES["a8"]!; i <= board.SQUARES["h1"]!; i++ {
            if (board[i] == nil) {
                empty++
            } else {
                if (empty > 0) {
                    fen += String(empty)
                    empty = 0
                }
                var color = board[i].color
                var piece = board[i].type
                
                fen += (color == GamePiece.Side.WHITE) ? piece.toUpperCase() : piece.toLowerCase()
            }
            
            if (i + 1) & 0x88 > 0 {
                if empty > 0 {
                    fen += String(empty)
                }
                
                if (i != board.SQUARES["h1"]) {
                    fen += "/"
                }
                
                empty = 0
                i += 8
            }
        }
        
        var cflags = ""
        if (castling[GamePiece.Side.WHITE]! & BITS.KSIDE_CASTLE.rawValue) { cflags += "K" }
        if (castling[GamePiece.Side.WHITE]! & BITS.QSIDE_CASTLE.rawValue) { cflags += "Q" }
        if (castling[GamePiece.Side.BLACK]! & BITS.KSIDE_CASTLE.rawValue) { cflags += "k" }
        if (castling[GamePiece.Side.BLACK]! & BITS.QSIDE_CASTLE.rawValue) { cflags += "q" }
        
        /* do we have an empty castling flag? */
        cflags = cflags || "-"
        var epflags = (ep_square == EMPTY) ? "-" : algebraic(ep_square)
        
        return [fen, turn, cflags, epflags, half_moves, move_number].componentsJoinedByString(" ")
    }
    
    func attacked(color: GamePiece.Side, square: Int) -> Bool {
        for var i = board.SQUARES["a8"]!; i <= board.SQUARES["h1"]!; i++ {
            /* did we run off the end of the board */
            if (i & 0x88 > 0) { i += 7; continue; }
            
            /* if empty square or wrong color */
            if board[i] == nil || board[i].color !== color {
                continue
            }
            
            var piece = board[i]
            var difference = i - square
            var index = difference + 119
            
            if ATTACKS[index] & (1 << SHIFTS[piece.type]) {
                if piece.type === GamePiece.Type.PAWN {
                    if difference > 0 {
                        if piece.color === GamePiece.Side.WHITE {
                            return true
                        }
                    } else {
                        if piece.color === GamePiece.Side.BLACK {
                            return true
                        }
                    }
                    continue
                }
                
                /* if the piece is a knight or a king */
                if (piece.type === "n" || piece.type === "k") {
                    return true
                }
                
                var offset = RAYS[index]
                var j = i + offset
                
                var blocked = false
                while j !== square {
                    if (board[j] != nil) {
                        blocked = true
                        break
                    }
                    j += offset
                }
                if (!blocked) {
                    return true
                }
            }
        }
        
        return false
    }
    
}
