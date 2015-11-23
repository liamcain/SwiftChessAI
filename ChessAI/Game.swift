import Foundation

class Game {
    
    
    let EMPTY = -1
    
    var board = GameBoard()
    
    var kings = [GamePiece.Side.WHITE: -1, GamePiece.Side.BLACK: -1]
    var ROOKS = [
        GamePiece.Side.WHITE: [
            ["square": 112, "flag": GameMove.Flag.QUEENSIDE_CASTLE.rawValue],
            ["square": 119, "flag": GameMove.Flag.KINGSIDE_CASTLE.rawValue]],
        GamePiece.Side.BLACK: [
            ["square": 0, "flag": GameMove.Flag.QUEENSIDE_CASTLE.rawValue],
            ["square": 7, "flag": GameMove.Flag.KINGSIDE_CASTLE.rawValue]]
        ]
    var castling = [GamePiece.Side.WHITE: 0, GamePiece.Side.BLACK: 0]
    var turn = GamePiece.Side.WHITE
    var ep_square = -1
    var half_moves = 0
    var move_number = 1
    var history = Array<GameMove>()
    var header = {}
    
    let DEFAULT_POSITION = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
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
        kings = [GamePiece.Side.WHITE: -1, GamePiece.Side.BLACK: -1]
        castling = [GamePiece.Side.WHITE: 0, GamePiece.Side.BLACK: 0]
        turn = GamePiece.Side.WHITE
        ep_square = EMPTY
        half_moves = 0
        move_number = 1
        history = []
    }
    
    func reset() {
        loadFromFen(DEFAULT_POSITION)
        turn = GamePiece.Side.WHITE
    }
    
    func put(piece: GamePiece, square: String) -> Bool {
        /* check for valid square */
        
        let sq = board.SQUARES[square]!
        
        /* don't let the user place more than one king */
        //        if (piece.kind == GamePiece.Kind.KING &&
        //            !(kings[piece.side] == EMPTY || kings[piece.color] == sq)) {
        //                return false;
        //        }
        
//        print("square: \(square). algebraic: \(sq). piece: \(piece.kind.rawValue)")
        board.set(sq, piece: piece)
        if (piece.kind == GamePiece.Kind.KING) {
            kings[piece.side] = sq
        }
        return true
    }
    
    func loadFromFen(fen: String) -> Bool {
        let tokens = fen.componentsSeparatedByString(" ")
        var position = Array(tokens[0].characters)
        var square = 0
        
        clear()
        
        for var i = 0; i < position.count; i++ {
            let piece = String(position[i])
            
            if piece == "/" {
                square += 8
            } else if let pieceValue = Int(piece) {
                square += pieceValue
            } else {
                put(GamePiece(str: piece), square: algebraic(square))
                square++
            }
        }
        
        turn = tokens[1] == "w" ? GamePiece.Side.WHITE : GamePiece.Side.BLACK
        
        if tokens[2].rangeOfString("K") != nil {
            castling[GamePiece.Side.WHITE]! |= GameMove.Flag.KINGSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("Q") != nil {
            castling[GamePiece.Side.WHITE]! |= GameMove.Flag.QUEENSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("k") != nil {
            castling[GamePiece.Side.BLACK]! |= GameMove.Flag.KINGSIDE_CASTLE.rawValue
        }
        if tokens[2].rangeOfString("q") != nil {
            castling[GamePiece.Side.BLACK]! |= GameMove.Flag.QUEENSIDE_CASTLE.rawValue
        }
        
        if tokens[3] == "-" {
            ep_square = EMPTY
        } else {
            ep_square = board.SQUARES[tokens[3]]!
        }
        half_moves = Int(tokens[4])!
        move_number = Int(tokens[5])!
       
        return true
    }
    
    func build_move(fromPosition: (Int, Int), toPosition: (Int, Int), promotionPiece: GamePiece.Kind?) -> GameMove {
        let from = (7 - fromPosition.1) * 16 + fromPosition.0
        let to   = (7 - toPosition.1) * 16 + toPosition.0
        return build_move(from, to: to, promotionPiece: promotionPiece)
    }
    
    func build_move(from: Int, to: Int, promotionPiece: GamePiece.Kind?) -> GameMove {
        assert(board.get(from) != nil)
        
        var flag = GameMove.Flag.NORMAL
//        print("Building Move: from \(algebraic(from)) to \(algebraic(to))")
        let movingPiece = board.get(from)!
        let capturedPiece = board.get(to)
        
        if capturedPiece != nil {
            if movingPiece.kind == GamePiece.Kind.PAWN {
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
        } else if movingPiece.kind == GamePiece.Kind.KING { // Handle castling
            if file(from) == 5 && file(to) == 7 {
                flag = GameMove.Flag.KINGSIDE_CASTLE
            } else if file(from) == 5 && file(to) == 3 {
                flag = GameMove.Flag.QUEENSIDE_CASTLE
            } else {
                flag = GameMove.Flag.NORMAL
            }
            board.disableCastling(turn)
        } else if movingPiece.kind == GamePiece.Kind.PAWN { // Handle PAWN_PROMOTION, PAWN_PUSH, and EN_PASSANT
            if rank(to) == 1 || rank(to) == 8 {
                flag = GameMove.Flag.PAWN_PROMOTION
            } else if rank(to) == rank(from) + 2 || rank(to) == rank(from) - 2 {
                flag = GameMove.Flag.PAWN_PUSH
            } else if file(to) != file(from) {
                flag = GameMove.Flag.EN_PASSANT
            }
        }
        let move = GameMove(side: turn, fromIndex: from, toIndex: to, flag: flag, promotionPiece: promotionPiece, capturedPiece: capturedPiece)
        move.side        = turn
        move.ep_square   = ep_square
        move.castling    = castling
        move.kings       = kings
        move.move_number = move_number
        move.half_moves  = half_moves
        return move
    }

    func rank(i: Int) -> Int {
        return i >> 4
    }
    
    func file(i: Int) -> Int {
        return i & 15
    }
    
    func algebraic(i: Int) -> String {
        let f = file(i)
        let r = 8 - rank(i)
        return "\(Character(UnicodeScalar(97+f)))\(r)"
    }
    
    func swap_color(c: GamePiece.Side) -> GamePiece.Side {
        return c == GamePiece.Side.WHITE ? GamePiece.Side.BLACK : GamePiece.Side.WHITE
    }
    
    func generate_moves(options: GameOptions) -> Array<GameMove> {
        var moves = Array<GameMove>()
        func add_move(from: Int, to: Int) {
            /* if pawn promotion */
            if board.get(from)!.kind == GamePiece.Kind.PAWN && (rank(to) == RANK_8 || rank(to) == RANK_1) {
                moves.append(build_move(from, to: to, promotionPiece: GamePiece.Kind.QUEEN));
                moves.append(build_move(from, to: to, promotionPiece: GamePiece.Kind.ROOK));
                moves.append(build_move(from, to: to, promotionPiece: GamePiece.Kind.KNIGHT));
                moves.append(build_move(from, to: to, promotionPiece: GamePiece.Kind.BISHOP));
                // let pieces = [GamePiece.Kind.QUEEN, GamePiece.Kind.ROOK, GamePiece.Kind.BISHOP, GamePiece.Kind.KNIGHT]
                // for var i = 0, len = pieces.count; i < len; i++ {
                //     temp.append(build_move(from, to: to, promotionPiece: GamePiece.Kind.BISHOP));
                // }
            } else {
                moves.append(build_move(from, to: to, promotionPiece: nil))
            }
        }
        
        let us = turn
        let them = (us == GamePiece.Side.WHITE) ? GamePiece.Side.BLACK : GamePiece.Side.WHITE
        let second_rank = [GamePiece.Side.BLACK: RANK_7, GamePiece.Side.WHITE: RANK_2]
        
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
            
            let piece = board.get(i)
            if piece == nil {
                continue;
            }
            let offsetArray = piece!.getOffsetArray()
            if piece!.side != us {
                continue
            }
            
            
            if piece!.kind == GamePiece.Kind.PAWN {
                /* single square, non-capturing */
                let square = i + offsetArray[0]
                
                if (board.get(square) == nil) {
                    add_move(i, to: square)
                    
                    /* double square */
                    let square = i + offsetArray[1]
                    if (second_rank[us] == rank(i) && board.get(square) == nil) {
                        add_move(i, to: square)
                    }
                }
                
                /* pawn captures */
                for var j = 2; j < 4; j++ {
                    let square = i + offsetArray[j]
                    if square & 0x88 > 0 {
                        continue
                    }
                    
                    if board.get(square) != nil && board.get(square)!.side == them {
                        add_move(i, to: square)
                    } else if square == ep_square {
                        add_move(i, to: ep_square)
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
                        if (board.get(square) == nil) {
                            add_move(i, to: square)
                        } else {
                            if (board.get(square)!.side == us) {
                                break
                            }
                            add_move(i, to: square)
                            break
                        }
                        
                        /* break, if knight or king */
                        if (piece!.kind == GamePiece.Kind.KNIGHT || piece!.kind == GamePiece.Kind.KING) {
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
            if castling[us] == GameMove.Flag.KINGSIDE_CASTLE.rawValue {
                let castling_from = kings[us]!
                let castling_to = castling_from + 2
                
                if board.get(castling_from + 1) == nil && board.get(castling_to) == nil && !attacked(them, square: kings[us]!) && !attacked(them, square: castling_from + 1) && !attacked(them, square: castling_to) {
                    add_move(kings[us]! , to: castling_to)
                }
            }
            
            /* queen-side castling */
            if castling[us]! == GameMove.Flag.QUEENSIDE_CASTLE.rawValue {
                let castling_from = kings[us]
                let castling_to = castling_from! - 2
                
                if board.get(castling_from! - 1) == nil && board.get(castling_from! - 2) == nil && board.get(castling_from! - 3) == nil && !attacked(them, square: kings[us]!) && !attacked(them, square: castling_from! - 1) && !attacked(them, square: castling_to) {
                    add_move(kings[us]!, to: castling_to)
                }
            }
        }
        
        /* return all pseudo-legal moves (this includes moves that allow the king
        * to be captured)
        */
        if (!legal) {
            return moves
        }
        
        /* filter out illegal moves */
        var legal_moves = Array<GameMove>()
        for var i = 0; i < moves.count; i++ {
            make_move(moves[i])
            if !king_attacked(us) {
                legal_moves.append(moves[i])
            }
            undo_move()
        }
        
        return legal_moves 
    }
    
    
    
    func generate_fen() -> String {
        var empty = 0
        var fen = ""
        
        for var i = board.SQUARES["a8"]!; i <= board.SQUARES["h1"]!; i++ {
            if (board.get(i) == nil) {
                empty++
            } else {
                if (empty > 0) {
                    fen += String(empty)
                    empty = 0
                }
                let color = board.get(i)!.side
                let piece = board.get(i)!.kind
                
                fen += (color == GamePiece.Side.WHITE) ? piece.rawValue.uppercaseString :piece.rawValue
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
        if (castling[GamePiece.Side.WHITE]! == GameMove.Flag.KINGSIDE_CASTLE.rawValue) { cflags += "K" }
        if (castling[GamePiece.Side.WHITE]! == GameMove.Flag.QUEENSIDE_CASTLE.rawValue) { cflags += "Q" }
        if (castling[GamePiece.Side.BLACK]! == GameMove.Flag.KINGSIDE_CASTLE.rawValue) { cflags += "k" }
        if (castling[GamePiece.Side.BLACK]! == GameMove.Flag.QUEENSIDE_CASTLE.rawValue) { cflags += "q" }
        
        /* do we have an empty castling flag? */
        if cflags == "" {
            cflags = "-"
        }
        let epflags = (ep_square == EMPTY) ? "-" : algebraic(ep_square)
        
        return [fen, String(turn), cflags, epflags, half_moves, move_number].componentsJoinedByString(" ")
    }
    
    func king_attacked(side: GamePiece.Side) -> Bool {
        return attacked(swap_color(side), square: kings[side]!)
    }
    
    func attacked(color: GamePiece.Side, square: Int) -> Bool {
        for var i = board.SQUARES["a8"]!; i <= board.SQUARES["h1"]!; i++ {
            /* did we run off the end of the board */
            if (i & 0x88 > 0) {
                i += 7
                continue
            }
            
            /* if empty square or wrong color */
            if board.get(i) == nil || board.get(i)!.side != color {
                continue
            }
            
            let piece = board.get(i)!
            let difference = i - square
            let index = difference + 119
            
            if (board.ATTACKS[index] & (1 << board.SHIFTS[piece.kind]!)) > 0 {
                if piece.kind == GamePiece.Kind.PAWN {
                    if difference > 0 {
                        if piece.side == GamePiece.Side.WHITE {
                            return true
                        }
                    } else {
                        if piece.side == GamePiece.Side.BLACK {
                            return true
                        }
                    }
                    continue
                }
                
                /* if the piece is a knight or a king */
                if (piece.kind == GamePiece.Kind.KING || piece.kind == GamePiece.Kind.KNIGHT) {
                    return true
                }
                
                let offset = board.RAYS[index]
                var j = i + offset
                
                var blocked = false
                while j != square {
                    if (board.get(j) != nil) {
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
    
    
    func undo_move() -> GameMove? {
        let old = history.popLast()
        if (old == nil) {
            return nil
        }
        
        let move = old!
        
        turn        = old!.side
        castling    = old!.castling!
        kings       = old!.kings!
        ep_square   = old!.ep_square!
        half_moves  = old!.half_moves!
        move_number = old!.move_number!
        
        let us = turn
        let them = swap_color(turn)
        
        board.set(move.fromIndex, piece: board.get(move.toIndex))
        if move.promotionPiece != nil {
            board.get(move.fromIndex)!.kind = move.promotionPiece!  // to undo any promotions
        }
        board.set(move.toIndex, piece: nil)
        
        if move.flag == GameMove.Flag.CAPTURE {
            board.set(move.toIndex, piece: GamePiece(side: them, kind: move.capturedPiece!.kind))
        } else if move.flag == GameMove.Flag.EN_PASSANT {
            var index: Int
            if (us == GamePiece.Side.BLACK) {
                index = move.toIndex - 16
            } else {
                index = move.toIndex + 16
            }
            board.set(index, piece: GamePiece(side: them, kind: GamePiece.Kind.PAWN))
        }
        
        
        if move.flag == GameMove.Flag.KINGSIDE_CASTLE || move.flag == GameMove.Flag.QUEENSIDE_CASTLE {
            var castling_to: Int?
            var castling_from: Int?
            if move.flag == GameMove.Flag.KINGSIDE_CASTLE {
                castling_to = move.toIndex + 1
                castling_from = move.toIndex - 1
            } else if move.flag == GameMove.Flag.QUEENSIDE_CASTLE {
                castling_to = move.toIndex - 2
                castling_from = move.toIndex + 1
            }
            
            if castling_from != nil {
                board.set(castling_to!, piece: board.get(castling_from!))
                board.set(castling_from!,  piece: nil)
            }
        }
        
        return move
    }
    
    func make_move(move: GameMove) {
        let us = turn
        let them = swap_color(us)
        history.append(move)
        
        board.set(move.toIndex, piece: board.get(move.fromIndex))
        board.set(move.fromIndex, piece: nil)
        
        /* if ep capture, remove the captured pawn */
        if move.flag == GameMove.Flag.EN_PASSANT {
            if turn == GamePiece.Side.BLACK {
                board.set(move.toIndex - 16,  piece: nil)
            } else {
                board.set(move.toIndex + 16, piece: nil)
            }
        }
        
        let piece = board.get(move.toIndex)
        
        /* if pawn promotion, replace with new piece */
        if move.flag == GameMove.Flag.PAWN_PROMOTION {
            board.set(move.toIndex, piece: GamePiece(side: us, kind: piece!.kind))
        }
        
        /* if we moved the king */
        if (piece != nil && piece?.kind == GamePiece.Kind.KING) {
            kings[piece!.side] = move.toIndex
            
            /* if we castled, move the rook next to the king */
            if move.flag == GameMove.Flag.KINGSIDE_CASTLE {
                let castling_to = move.toIndex - 1
                let castling_from = move.toIndex + 1
                board.set(castling_to, piece: board.get(castling_from))
                board.set(castling_from, piece: nil)
            } else if move.flag == GameMove.Flag.QUEENSIDE_CASTLE {
                let castling_to = move.toIndex + 1
                let castling_from = move.toIndex - 2
                board.set(castling_to, piece: board.get(castling_from))
                board.set(castling_from, piece: nil)
            }
            
            /* turn off castling */
            castling[us] = 0
        }
        
        
        /* turn off castling if we move a rook */
        if castling[us] != nil {
            for var i = 0, len = ROOKS[us]!.count; i < len; i++ {
                if move.fromIndex == ROOKS[us]![i]["square"]! &&
                    castling[us]! & ROOKS[us]![i]["flag"]! > 0 {
                        castling[us]! ^= ROOKS[us]![i]["flag"]!
                        break
                }
            }
        }
        
        /* turn off castling if we capture a rook */
        if castling[them] != nil {
            for (var i = 0, len = ROOKS[them]!.count; i < len; i++) {
                if move.toIndex == ROOKS[them]![i]["square"]! &&
                    castling[them]! & ROOKS[them]![i]["flag"]! > 0 {
                        castling[them]! ^= ROOKS[them]![i]["flag"]!
                        break
                }
            }
        }
        
        /* if big pawn move, update the en passant square */
        if move.flag == GameMove.Flag.PAWN_PUSH {
            if turn == GamePiece.Side.BLACK {
                ep_square = move.toIndex - 16
            } else {
                ep_square = move.toIndex + 16
            }
        } else {
            ep_square = EMPTY;
        }
        
        /* reset the 50 move counter if a pawn is moved or a piece is captured */
        if board.get(move.toIndex) != nil && board.get(move.toIndex)!.kind == GamePiece.Kind.PAWN {
            half_moves = 0
        } else if move.flag == GameMove.Flag.CAPTURE || move.flag == GameMove.Flag.EN_PASSANT {
            half_moves = 0
        } else {
            half_moves++
        }
        
        if turn == GamePiece.Side.BLACK {
            move_number++
        }
        turn = swap_color(turn)
    }
    
    func print_board()  {
        let first_sq = board.SQUARES["a8"]
        let last_sq = board.SQUARES["h1"]
        print("Move number: \(move_number)\n")
        
        var line = ""
        for var i = first_sq!; i <= last_sq!; i++ {
            if let piece = board.get(i) {
                let kind = Array(arrayLiteral: piece.kind.rawValue)[0]
                if piece.side == GamePiece.Side.BLACK {
                    line += " \(kind.uppercaseString) "
                } else {
                    line += " \(kind) "
                }
            } else {
                line += " □ "
            }
            if i % 8 == 7 {
                print(line)
                line = ""
                i += 8
            }
        }
        print("\n\n")
    }
    
}
