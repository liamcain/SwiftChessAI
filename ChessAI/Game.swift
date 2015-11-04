import Foundation

class Game {
    
    let BLACK = "b"
    let WHITE = "w"
    
    let EMPTY = -1
    
    // TODO change to type enum
    let PAWN = "p"
    let KNIGHT = "n"
    let BISHOP = "b"
    let ROOK = "r"
    let QUEEN = "q"
    let KING = "k"
    
    var board = Array<Int>(arrayLiteral: 128)
    var kings = ["w": -1, "b": -1]
    var turn = "w"
    var castling = ["w": 0, "b": 0]
    var ep_square = -1
    var half_moves = 0
    var move_number = 1
    var history = []
    var header = {}
    
    enum BITS: Int {
        case NORMAL = 1
        case CAPTURE = 2
        case BIG_PAWN = 4
        case EP_CAPTURE = 8
        case PROMOTION = 16
        case KSIDE_CASTLE = 32
        case QSIDE_CASTLE = 64
    };
    
    let SQUARES = [
        "a8":   0, "b8":   1, "c8":   2, "d8":   3, "e8":   4, "f8":   5, "g8":   6, "h8":   7,
        "a7":  16, "b7":  17, "c7":  18, "d7":  19, "e7":  20, "f7":  21, "g7":  22, "h7":  23,
        "a6":  32, "b6":  33, "c6":  34, "d6":  35, "e6":  36, "f6":  37, "g6":  38, "h6":  39,
        "a5":  48, "b5":  49, "c5":  50, "d5":  51, "e5":  52, "f5":  53, "g5":  54, "h5":  55,
        "a4":  64, "b4":  65, "c4":  66, "d4":  67, "e4":  68, "f4":  69, "g4":  70, "h4":  71,
        "a3":  80, "b3":  81, "c3":  82, "d3":  83, "e3":  84, "f3":  85, "g3":  86, "h3":  87,
        "a2":  96, "b2":  97, "c2":  98, "d2":  99, "e2": 100, "f2": 101, "g2": 102, "h2": 103,
        "a1": 112, "b1": 113, "c1": 114, "d1": 115, "e1": 116, "f1": 117, "g1": 118, "h1": 119
    ]
    
    let RANK_1 = 7
    let RANK_2 = 6
    let RANK_3 = 5
    let RANK_4 = 4
    let RANK_5 = 3
    let RANK_6 = 2
    let RANK_7 = 1
    let RANK_8 = 0
    
    func clear() {
        board = Array(arrayLiteral: 128)
        kings = ["w": EMPTY, "b": EMPTY]
        turn = "w"
        castling = ["w": 0, "b": 0]
        ep_square = EMPTY
        half_moves = 0
        move_number = 1
        history = []
//        header = []
        update_setup(generate_fen())
    }
    
    func reset() {
        load(DEFAULT_POSITION)
    }

    func load(fen: String) -> bool {
        let tokens = fen.componentsSeparatedByString(" ")
        let position = tokens[0]
        let square = 0
        
//        if !validate_fen(fen).valid {
//            return false
//        }
        
        clear()
        
        for let i = 0; i < position.length; i++ {
            let piece = position.charAt(i);
            
            if piece === "/" {
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
        
        ep_square = (tokens[3] === "-") ? EMPTY : SQUARES[tokens[3]]
        half_moves = Int(tokens[4])
        move_number = Int(tokens[5])
        
        update_setup(generate_fen())
        
        return true
    }
    
    
    func update_setup(fen: String) {
        if history.count > 0 {
            return
        }
        
//        if fen !== DEFAULT_POSITION {
//            header["SetUp"] = "1"
//            header["FEN"] = fen
//        } else {
//            delete header["SetUp"]
//            delete header["FEN"]
//        }
    }
    
    func build_move(board: [Int], from: Int, to: Int, flags: Int, promotion: Int) -> Dictionary<String, AnyObject> {
        var move = [
            "color": turn,
            "from": from,
            "to": to,
            "flags": flags,
            "piece": board[from]["type"]
        ]
    
        if promotion > -1{
            move.flags |= BITS.PROMOTION
            move.promotion = promotion
        }
        
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
        func add_move(board: Dictionary<Int, Piece>, moves: Array<Int>, from: Int, to: Int, flags: Int) {
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
            
            let piece = board[i]
            if piece["color"] !== us {
                continue
            }
            
            if (piece["type"] === PAWN) {
                /* single square, non-capturing */
                let square = i + PAWN_OFFSETS[us][0]
                if (board[square] == nil) {
                    add_move(board, moves, i, square, BITS.NORMAL);
                    
                    /* double square */
                    let square = i + PAWN_OFFSETS[us][1];
                    if (second_rank[us] === rank(i) && board[square] == nil) {
                        add_move(board, moves, i, square, BITS.BIG_PAWN);
                    }
                }
                
                /* pawn captures */
                for var j = 2; j < 4; j++ {
                    let square = i + PAWN_OFFSETS[us][j]
                    if square & 0x88 {
                        continue
                    }
                    
                    if (board[square] != nil &&
                        board[square].color === them) {
                            add_move(board, moves, i, square, BITS.CAPTURE);
                    } else if (square === ep_square) {
                        add_move(board, moves as! Array<Int>, i, ep_square, BITS.EP_CAPTURE);
                    }
                }
            } else {
                for var j = 0, len = PIECE_OFFSETS[piece.type].length; j < len; j++ {
                    let offset = PIECE_OFFSETS[piece.type][j];
                    let square = i;
                    
                    while (true) {
                        square += offset
                        if square & 0x88 {
                            break
                        }
                        if (board[square] == nil) {
                            add_move(board, moves, i, square, BITS.NORMAL)
                        } else {
                            if (board[square].color === us) {
                                break
                            }
                            add_move(board, moves, i, square, BITS.CAPTURE)
                            break;
                        }
                        
                        /* break, if knight or king */
                        if (piece.type === "n" || piece.type === "k") {
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
    
}
