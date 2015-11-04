import Foundation

class Game {
    
    
    let EMPTY = -1
    
    var board = GameBoard();
    
    var kings = ["w": -1, "b": -1]
    var turn = GamePiece.Side.WHITE
    var castling = ["w": 0, "b": 0]
    var ep_square = -1
    var half_moves = 0
    var move_number = 1
    var history = []
    var header = {}
    
    let DEFAULT_POSITION = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    
    enum BITS: Int {
        case NORMAL = 1
        case CAPTURE = 2
        case BIG_PAWN = 4
        case EP_CAPTURE = 8
        case PROMOTION = 16
        case KSIDE_CASTLE = 32
        case QSIDE_CASTLE = 64
    };
    
    
    
    let RANK_1 = 7
    let RANK_2 = 6
    let RANK_3 = 5
    let RANK_4 = 4
    let RANK_5 = 3
    let RANK_6 = 2
    let RANK_7 = 1
    let RANK_8 = 0
    
    func clear() {
        board = GameBoard();
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
    
    func loadFromFen(fen: String) {
        let tokens = fen.componentsSeparatedByString(" ")
        let position = tokens[0]
        let square = 0
        
        //        if !validate_fen(fen).valid {
        //            return false
        //        }
        
        clear()
        
        for let i = 0; i < position.length; i++ {
            let piece = position.charAt(i);
            
            if piece == "/" {
                square += 8;
            } else if is_digit(piece) {
                square += parseInt(piece, 10);
            } else {
                let color = (piece < "a") ? WHITE : BLACK;
                put(["type": piece.toLowerCase(), "color": color], algebraic(square));
                square++;
            }
        }
        
        turn = tokens[1]
        
        if tokens[2].indexOf("K") > -1 {
            castling["b"]! |= BITS.KSIDE_CASTLE.rawValue;
        }
        if tokens[2].indexOf("Q") > -1 {
            castling["w"]! |= BITS.QSIDE_CASTLE.rawValue;
        }
        if tokens[2].indexOf("k") > -1 {
            castling["b"]! |= BITS.KSIDE_CASTLE.rawValue;
        }
        if tokens[2].indexOf("q") > -1 {
            castling["b"]! |= BITS.QSIDE_CASTLE.rawValue;
        }
        
        ep_square = (tokens[3] == "-") ? EMPTY : SQUARES[tokens[3]]
        half_moves = Int(tokens[4])
        move_number = Int(tokens[5])
        
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
    
    func build_move(from: Int, to: Int, flag: GameMove.Flag, promotionPiece: GamePiece) -> Dictionary<String, AnyObject> {
        var move = GameMove(side: turn, fromIndex: from, toIndex: to, flag: flag, promotionPiece: promotionPiece)
        
        if board[to] > -1 {
            move.captured = board[to].type;
        } else if flags & BITS.EP_CAPTURE.rawValue {
            move.captured = PAWN;
        }
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
    
    func swap_color(c: String) -> String {
        return c == WHITE ? BLACK : WHITE
    }
    
    func generate_moves(options: Dictionary<String, String>) -> Array<Int> {
        func add_move(board: Dictionary<Int, GamePiece>, moves: Array<Int>, from: Int, to: Int, flags: Int) {
            /* if pawn promotion */
            if (board[from]!.type == PAWN &&
                (rank(to) == RANK_8 || rank(to) == RANK_1)) {
                    let pieces = [QUEEN, ROOK, BISHOP, KNIGHT]
                    for var i = 0; len = pieces.length; i < len; i++ {
                        moves.push(build_move(board, from, to, flags, pieces[i]));
                    }
            } else {
                moves.push(build_move(board, from, to, flags))
            }
        }
        
        let moves = []
        let us = turn
        let them = swap_color(us)
        let second_rank = ["b": RANK_7, "w": RANK_2]
        
        var first_sq = SQUARES["a8"]
        var last_sq = SQUARES["h1"]
        var single_square = false
        
        /* do we want legal moves? */
        let legal = contains(options, "legal") ? options["legal"] : true;
        
        /* are we generating moves for a single square? */
        if contains(options, "legal") {
            if contains(SQUARES, options["square"]) {
                first_sq = last_sq = SQUARES[options["square"]]
                single_square = true
            } else {
                /* invalid square */
                return [];
            }
        }
        
        for var i = first_sq!; i <= last_sq!; i++ {
            /* did we run off the end of the board */
            if i & 0x88 {
                i += 7
                continue
            }
            
            let piece: GamePiece = board[i]
            let offsetArray = piece.getOffsetArray();
            if piece.side != us {
                continue
            }
            
            
            if (piece.type == GamePiece.Type.PAWN) {
                /* single square, non-capturing */
                let square = i + offsetArray[us][0]
                
                if (board[square] == nil) {
                    add_move(board, moves, i, square, BITS.NORMAL);
                    
                    /* double square */
                    let square = i + offsetArray[us][1];
                    if (second_rank[us] == rank(i) && board[square] == nil) {
                        add_move(board, moves, i, square, BITS.BIG_PAWN);
                    }
                }
                
                /* pawn captures */
                for var j = 2; j < 4; j++ {
                    let square = i + offsetArray[us][j]
                    if square & 0x88 {
                        continue
                    }
                    
                    if (board[square] != nil &&
                        board[square].color == them) {
                            add_move(board, moves, i, square, BITS.CAPTURE);
                    } else if (square == ep_square) {
                        add_move(board, moves as! Array<Int>, i, ep_square, BITS.EP_CAPTURE);
                    }
                }
            } else {
                for var j = 0, len = offsetArray[piece.type].length; j < len; j++ {
                    let offset = offsetArray[piece.type][j];
                    let square = i;
                    
                    while (true) {
                        square += offset
                        if square & 0x88 {
                            break
                        }
                        if (board[square] == nil) {
                            add_move(board, moves, i, square, BITS.NORMAL)
                        } else {
                            if (board[square].color == us) {
                                break
                            }
                            add_move(board, moves, i, square, BITS.CAPTURE)
                            break;
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
            if (castling[us]! & BITS.KSIDE_CASTLE.rawValue) {
                let castling_from = kings[us]
                let castling_to = castling_from! + 2
                
                if (board[castling_from + 1] == nil && board[castling_to] == nil && !attacked(them, kings[us]) && !attacked(them, castling_from + 1) && !attacked(them, castling_to)) {
                    add_move(board, moves: moves as! Array<Int>, from: kings[us]! , to: castling_to, flags: BITS.KSIDE_CASTLE.rawValue)
                }
            }
            
            /* queen-side castling */
            if (castling[us]! & BITS.QSIDE_CASTLE.rawValue) {
                let castling_from = kings[us];
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
        
        for var i = SQUARES["a8"]!; i <= SQUARES["h1"]!; i++ {
            if (board[i] == nil) {
                empty++
            } else {
                if (empty > 0) {
                    fen += String(empty)
                    empty = 0
                }
                var color = board[i].color
                var piece = board[i].type
                
                fen += (color == WHITE) ?
                    piece.toUpperCase() : piece.toLowerCase()
            }
            
            if (i + 1) & 0x88 {
                if empty > 0 {
                    fen += String(empty)
                }
                
                if (i != SQUARES["h1"]) {
                    fen += "/"
                }
                
                empty = 0
                i += 8
            }
        }
        
        var cflags = ""
        if (castling[WHITE]! & BITS.KSIDE_CASTLE.rawValue) { cflags += "K" }
        if (castling[WHITE]! & BITS.QSIDE_CASTLE.rawValue) { cflags += "Q" }
        if (castling[BLACK]! & BITS.KSIDE_CASTLE.rawValue) { cflags += "k" }
        if (castling[BLACK]! & BITS.QSIDE_CASTLE.rawValue) { cflags += "q" }
        
        /* do we have an empty castling flag? */
        cflags = cflags || "-"
        var epflags = (ep_square == EMPTY) ? "-" : algebraic(ep_square)
        
        return [fen, turn, cflags, epflags, half_moves, move_number].componentsJoinedByString(" ")
    }
    
}
