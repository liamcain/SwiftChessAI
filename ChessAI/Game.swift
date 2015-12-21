import Foundation


func == (lhs: Game, rhs: Game) -> Bool {
    return lhs.generateFen() == rhs.generateFen()
}

class Game: Equatable {
    let EMPTY = -1
    var board = GameBoard()
    
    var bKing: Int             =    4
    var bKingsideCastle: Bool  = true
    var bQueensideCastle: Bool = true
    
    var wKing: Int             =  116
    var wKingsideCastle: Bool  = true
    var wQueensideCastle: Bool = true
    
    var turn = Side.WHITE
    var epSquare = -1
    var halfMoves = 0
    var moveNumber = 1
    var history = Array<GameMove>()
    
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
        bKing            =    4
        bKingsideCastle  = true
        bQueensideCastle = true
        
        wKing            =  116
        wKingsideCastle  = true
        wQueensideCastle = true
        
        turn = Side.WHITE
        epSquare = EMPTY
        halfMoves = 0
        moveNumber = 1
        history = []
    }
    
    func setKing(pos: Int)                         { if turn == .BLACK { bKing = pos           } else { wKing = pos           } }
    func setKing(pos: Int, side: Side)             { if side == .BLACK { bKing = pos           } else { wKing = pos           } }
    func setKingSideCastle(en: Bool)               { if turn == .BLACK { bKingsideCastle  = en } else { wKingsideCastle  = en } }
    func setKingSideCastle(en: Bool, side: Side)   { if side == .BLACK { bKingsideCastle  = en } else { wKingsideCastle  = en } }
    func setQueenSideCastle(en: Bool)              { if turn == .BLACK { bQueensideCastle = en } else { wQueensideCastle = en } }
    func setQueenSideCastle(en: Bool, side: Side)  { if side == .BLACK { bQueensideCastle = en } else { wQueensideCastle = en } }
    
    func king()                      -> Int  { if turn == .BLACK { return bKing            } else { return wKing            } }
    func king(side: Side)            -> Int  { if side == .BLACK { return bKing            } else { return wKing            } }
    func kingSideCastle()            -> Bool { if turn == .BLACK { return bKingsideCastle  } else { return wKingsideCastle  } }
    func kingSideCastle(side: Side)  -> Bool { if side == .BLACK { return bKingsideCastle  } else { return wKingsideCastle  } }
    func queenSideCastle()           -> Bool { if turn == .BLACK { return bQueensideCastle } else { return wQueensideCastle } }
    func queenSideCastle(side: Side) -> Bool { if side == .BLACK { return bQueensideCastle } else { return wQueensideCastle } }
    func secondRank()                -> Int  { if turn == .BLACK { return RANK_7           } else { return RANK_2 } }
    
    func copy() -> Game {
        let copy        = Game()
        copy.turn       = turn
        copy.epSquare   = epSquare
        copy.halfMoves  = halfMoves
        copy.moveNumber = moveNumber
        copy.history    = history
        copy.board      = board.copy()
        return copy
    }
    
    func reset() {
        loadFromFen(DEFAULT_POSITION)
        turn = Side.WHITE
    }
    
    func put(piece: GamePiece, square: String) -> Bool {
        let sq = board.SQUARES[square]!
        
        board.set(sq, piece: piece)
        if (piece.kind == Kind.KING) {
            setKing(sq, side: piece.side)
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
        
        turn = tokens[1] == "w" ? .WHITE : .BLACK
        
        if tokens[2].rangeOfString("K") != nil { setKingSideCastle(false,  side: .WHITE) }
        if tokens[2].rangeOfString("Q") != nil { setQueenSideCastle(false, side: .WHITE) }
        if tokens[2].rangeOfString("k") != nil { setKingSideCastle(false,  side: .BLACK) }
        if tokens[2].rangeOfString("q") != nil { setQueenSideCastle(false, side: .BLACK) }
        
        if tokens[3] == "-" {
            epSquare = EMPTY
        } else {
            epSquare = board.SQUARES[tokens[3]]!
        }
        halfMoves = Int(tokens[4])!
        moveNumber = Int(tokens[5])!
       
        return true
    }
    
    func buildMove(fromPosition: (Int, Int), toPosition: (Int, Int), promotionPiece: Kind?) -> GameMove {
        let from = (7 - fromPosition.1) * 16 + fromPosition.0
        let to   = (7 - toPosition.1)   * 16 + toPosition.0
        return buildMove(from, to: to, promotionPiece: promotionPiece)
    }
    
    func buildMove(from: Int, to: Int, promotionPiece: Kind?) -> GameMove {
        assert(board.get(from) != nil)
        
        var flag: GameMove.Flag = .NORMAL
        let movingPiece = board.get(from)!
        let capturedPiece = board.get(to)
        
        if capturedPiece != nil {
            if movingPiece.kind == Kind.PAWN {
                if rank(to) == RANK_1 || rank(to) == RANK_8 {
                    // Pawn captured and needs to be promoted
                    flag = .PAWN_PROMOTION_CAPTURE
                } else {
                    // Pawn only captures
                    flag = .CAPTURE
                }
            } else {
                flag = .CAPTURE
            }
        } else if movingPiece.kind == .KING { // Handle castling
            if file(from) == 4 && file(to) == 6 {
                flag = .KINGSIDE_CASTLE
            } else if file(from) == 4 && file(to) == 2 {
                flag = .QUEENSIDE_CASTLE
            } else {
                flag = .NORMAL
            }
            setKingSideCastle(false)
            setQueenSideCastle(false)
        } else if movingPiece.kind == .PAWN { // Handle PAWN_PROMOTION, PAWN_PUSH, and EN_PASSANT
            if rank(to) == RANK_1 || rank(to) == RANK_8 {
                flag = .PAWN_PROMOTION
            } else if rank(to) == rank(from) + 2 || rank(to) == rank(from) - 2 {
                flag = .PAWN_PUSH
            } else if file(to) != file(from) {
                flag = .EN_PASSANT
            }
        }
        let move = GameMove(side: turn, fromIndex: from, toIndex: to, flag: flag, promotionPiece: promotionPiece, capturedPiece: capturedPiece)
        move.side        = turn
        move.epSquare    = epSquare
        move.moveNumber  = moveNumber
        move.halfMoves   = halfMoves
        move.wKing            = wKing
        move.wKingsideCastle  = wKingsideCastle
        move.wQueensideCastle = wQueensideCastle
        move.bKing            = bKing
        move.bKingsideCastle  = bKingsideCastle
        move.bQueensideCastle = bQueensideCastle
        
        return move
    }
    
    func kindName(kind: Kind) -> String {
        switch kind {
        case .BISHOP: return "b"
        case .KING:   return "k"
        case .KNIGHT: return "n"
        case .PAWN:   return "p"
        case .QUEEN:  return "q"
        case .ROOK:   return "r"
        }
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
    
    func swapColor(c: Side) -> Side {
        return c == .WHITE ? .BLACK : .WHITE
    }
    
    func generateMoves(options: GameOptions) -> Array<GameMove> {
        var moves = Array<GameMove>()
        func addMove(from: Int, to: Int) {
            /* if pawn promotion */
            if board.get(from)?.kind == .PAWN && (rank(to) == RANK_8 || rank(to) == RANK_1) {
                moves.append(buildMove(from, to: to, promotionPiece: .QUEEN));
//                moves.append(buildMove(from, to: to, promotionPiece: .ROOK));
//                moves.append(buildMove(from, to: to, promotionPiece: .KNIGHT));
//                moves.append(buildMove(from, to: to, promotionPiece: .BISHOP));
            } else {
                moves.append(buildMove(from, to: to, promotionPiece: nil))
            }
        }
        
        let us = turn
        let them = swapColor(us)
        let secondRank = turn == .BLACK ?RANK_7 :RANK_2
        
        /* do we want legal moves? */
        let legal = options.legal != nil ?options.legal! :true
        
        for var i = 0; i < 120; i++ {
            /* did we run off the end of the board */
            if i & 0x88 > 0 {
                i += 7
                continue
            }
            
            let piece = board.get(i)
            if piece == nil {
                continue
            }
            let offsetArray = piece!.getOffsetArray()
            if piece!.side != us {
                continue
            }
            
            if piece!.kind == Kind.PAWN {
                /* single square, non-capturing */
                let square = i + offsetArray[0]
                
                if (board.get(square) == nil) {
                    addMove(i, to: square)
                    
                    /* double square */
                    let square = i + offsetArray[1]
                    if (secondRank == rank(i) && board.get(square) == nil) {
                        addMove(i, to: square)
                    }
                }
                
                /* pawn captures */
                for var j = 2; j < 4; j++ {
                    let square = i + offsetArray[j]
                    if square & 0x88 > 0 {
                        continue
                    }
                    
                    if board.get(square) != nil && board.get(square)!.side == them {
                        addMove(i, to: square)
                    } else if square == epSquare {
                        addMove(i, to: epSquare)
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
                            addMove(i, to: square)
                        } else {
                            if (board.get(square)!.side == us) {
                                break
                            }
                            addMove(i, to: square)
                            break
                        }
                        
                        /* break, if knight or king */
                        if (piece!.kind == .KNIGHT || piece!.kind == .KING) {
                            break
                        }
                    }
                }
            }
        }
        
        /* check for castling if: a) we're generating all moves, or b) we're doing
        * single square move generation on the king's square
        */
            /* king-side castling */
        if kingSideCastle() {
            let castlingFrom = king()
            let castlingTo = castlingFrom + 2
            
            if board.get(castlingFrom + 1) == nil
                && board.get(castlingTo) == nil
                && !attacked(them, square: king())
                && !attacked(them, square: castlingFrom + 1)
                && !attacked(them, square: castlingTo) {
                    addMove(king(), to: castlingTo)
            }
        }
        
        /* queen-side castling */
        if queenSideCastle() {
            let castlingFrom = king()
            let castlingTo = castlingFrom - 2
            if board.get(castlingFrom - 1) == nil && board.get(castlingFrom - 2) == nil
                && board.get(castlingFrom - 3) == nil
                && !attacked(them, square: king())
                && !attacked(them, square: castlingFrom - 1)
                && !attacked(them, square: castlingTo) {
                addMove(king(), to: castlingTo)
            }
        }
    
        /* return all pseudo-legal moves (this includes moves that allow the king
        * to be captured)
        */
        if (!legal) {
            return moves
        }
        
        /* filter out illegal moves */
        var legalMoves = Array<GameMove>()
        for var i = 0; i < moves.count; i++ {
            makeMove(moves[i])
            if !inCheck(us) {
                legalMoves.append(moves[i])
            }
            undoMove()
        }
        
        return legalMoves
    }
    
    
    
    func generateFen() -> String {
        var empty = 0
        var fen = ""
        
        for var i = 0; i < 120; i++ {
            if (board.get(i) == nil) {
                empty++
            } else {
                if (empty > 0) {
                    fen += String(empty)
                    empty = 0
                }
                let color = board.get(i)!.side
                let piece = board.get(i)!.kind
                
                fen += (color == .WHITE) ? kindName(piece).uppercaseString :kindName(piece)
            }
            
            if (i + 1) & 0x88 > 0 {
                if empty > 0 {
                    fen += String(empty)
                }
                if i != 119 { // Square H1
                    fen += "/"
                }
                empty = 0
                i += 8
            }
        }
        
        var cflags = ""
        if (kingSideCastle(.WHITE))  { cflags += "K" }
        if (queenSideCastle(.WHITE)) { cflags += "Q" }
        if (kingSideCastle(.BLACK))  { cflags += "k" }
        if (queenSideCastle(.BLACK)) { cflags += "q" }
        
        /* do we have an empty castling flag? */
        if cflags == "" {
            cflags = "-"
        }
        let epflags = (epSquare == EMPTY) ? "-" : algebraic(epSquare)
        
        return [fen, String(turn), cflags, epflags, halfMoves, moveNumber].componentsJoinedByString(" ")
    }
    
    func inCheck(side: Side) -> Bool {
        return attacked(swapColor(side), square: king(side))
    }
    
    func attacked(color: Side, square: Int) -> Bool {
        for var i = 0; i < 120; i++ {
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
            
            if board.ATTACKS[index] & 1 << piece.getShift() > 0 {
                if piece.kind == Kind.PAWN {
                    if difference > 0 {
                        if piece.side == Side.WHITE {
                            return true
                        }
                    } else {
                        if piece.side == Side.BLACK {
                            return true
                        }
                    }
                    continue
                }
                
                /* if the piece is a knight or a king */
                if (piece.kind == .KING || piece.kind == .KNIGHT) {
                    return true
                }
                
                let offset = board.RAYS[index]
                var j = i + offset
                
                var blocked = false
                while j != square {
                    if board.get(j) != nil {
                        blocked = true
                        break
                    }
                    j += offset
                }
                if !blocked {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    func undoMove() -> GameMove? {
        let old = history.popLast()
        if (old == nil) {
            return nil
        }
        
        let move = old!

        bKing            = move.bKing
        bKingsideCastle  = move.bKingsideCastle
        bQueensideCastle = move.bQueensideCastle
        wKing            = move.wKing
        wKingsideCastle  = move.wKingsideCastle
        wQueensideCastle = move.wQueensideCastle

        turn        = move.side
        epSquare    = move.epSquare
        halfMoves   = move.halfMoves
        moveNumber  = move.moveNumber
        
        let us   = turn
        let them = swapColor(turn)
        
        board.set(move.fromIndex, piece: board.get(move.toIndex))
        if move.promotionPiece != nil {
            board.get(move.fromIndex)!.kind = move.promotionPiece!  // to undo any promotions
        }
        board.set(move.toIndex, piece: nil)
        
        if move.flag == .CAPTURE {
            board.set(move.toIndex, piece: GamePiece(side: them, kind: move.capturedPiece!.kind))
        } else if move.flag == GameMove.Flag.EN_PASSANT {
            var index: Int
            if (us == Side.BLACK) {
                index = move.toIndex - 16
            } else {
                index = move.toIndex + 16
            }
            board.set(index, piece: GamePiece(side: them, kind: Kind.PAWN))
        }
        
        if move.flag == .KINGSIDE_CASTLE || move.flag == .QUEENSIDE_CASTLE {
            var castlingTo: Int?
            var castlingFrom: Int?
            if move.flag == .KINGSIDE_CASTLE {
                castlingTo = move.toIndex + 1
                castlingFrom = move.toIndex - 1
            } else if move.flag == .QUEENSIDE_CASTLE {
                castlingTo = move.toIndex - 2
                castlingFrom = move.toIndex + 1
            }
            
            if castlingFrom != nil {
                board.set(castlingTo!, piece: board.get(castlingFrom!))
                board.set(castlingFrom!,  piece: nil)
            }
        }
        
        return move
    }
    
    func makeMove(move: GameMove) {
        history.append(move)
        
        board.set(move.toIndex, piece: board.get(move.fromIndex))
        board.set(move.fromIndex, piece: nil)
        
        /* if ep capture, remove the captured pawn */
        if move.flag == GameMove.Flag.EN_PASSANT {
            if turn == Side.BLACK {
                board.set(move.toIndex - 16,  piece: nil)
            } else {
                board.set(move.toIndex + 16, piece: nil)
            }
        }
        
        let piece = board.get(move.toIndex)
        
        /* if pawn promotion, replace with new piece */
        if move.flag == .PAWN_PROMOTION || move.flag == .PAWN_PROMOTION_CAPTURE {
            board.set(move.toIndex, piece: GamePiece(side: turn, kind: move.promotionPiece!))
        }
        
        /* if we moved the king */
        if (piece != nil && piece?.kind == .KING) {
            setKing(move.toIndex, side: piece!.side)
            
            /* if we castled, move the rook next to the king */
            if move.flag == .KINGSIDE_CASTLE {
                let castlingTo = move.toIndex - 1
                let castlingFrom = move.toIndex + 1
                board.set(castlingTo, piece: board.get(castlingFrom))
                board.set(castlingFrom, piece: nil)
            } else if move.flag == .QUEENSIDE_CASTLE {
                let castlingTo = move.toIndex + 1
                let castlingFrom = move.toIndex - 2
                board.set(castlingTo, piece: board.get(castlingFrom))
                board.set(castlingFrom, piece: nil)
            }
            
            /* turn off castling */
            setKingSideCastle(false, side: move.side)
            setQueenSideCastle(false, side: move.side)
        }
        
        /* turn off castling if we move a rook */
        if piece?.kind == .ROOK {
            if move.fromIndex == 112 || move.toIndex == 112 {
                setQueenSideCastle(false, side: .WHITE)
            } else if move.fromIndex == 119 || move.toIndex == 119 {
                setKingSideCastle(false, side: .WHITE)
            } else if move.fromIndex == 0 || move.toIndex == 0 {
                setQueenSideCastle(false, side: .BLACK)
            } else if move.fromIndex == 7 || move.toIndex == 7 {
                setKingSideCastle(false, side: .BLACK)
            }
        }
        
        /* if big pawn move, update the en passant square */
        if move.flag == .PAWN_PUSH {
            if turn == .BLACK {
                epSquare = move.toIndex - 16
            } else {
                epSquare = move.toIndex + 16
            }
        } else {
            epSquare = EMPTY
        }
        
        /* reset the 50 move counter if a pawn is moved or a piece is captured */
        if board.get(move.toIndex) != nil && board.get(move.toIndex)!.kind == .PAWN {
            halfMoves = 0
        } else if move.flag == .CAPTURE || move.flag == .EN_PASSANT {
            halfMoves = 0
        } else {
            halfMoves++
        }
        if turn == .BLACK {
            moveNumber++
        }
        turn = swapColor(turn)
    }
    
    func printBoard() {
        print("Move number: \(moveNumber)\n")
        
        var line = ""
        for var i = 0; i < 120; i++ {
            if let piece = board.get(i) {
                let kind = Array(arrayLiteral: kindName(piece.kind))[0]
                if piece.side == Side.BLACK {
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
    
    func inStatemate() -> Bool {
        let moves = generateMoves(GameOptions())
        return !inCheck(turn) && moves.count == 0
    }
    
    func inCheckmate() -> Bool {
        let moves = generateMoves(GameOptions())
        return inCheck(turn) && moves.count == 0
    }
    
}
