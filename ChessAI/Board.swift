//
//  board.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Board: SKNode {
    
    var DEFAULT_POSITION = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    
    var spaces: [[Space]] = [[Space]]()
    var pieces: [[Piece?]] = [[Piece?]]()
    
    override init() {
        super.init()
        
        for i in 0...7 {
            var pieceRow = Array<Piece?>()
            var spaceRow = Array<Space>()
            for j in 0...7 {
                pieceRow.append(nil)
                
                var space: Space
                if (i + j) % 2 == 0 {
                    space = Space(color: Space.Color.BLACK, space: (j, i))
                } else {
                    space = Space(color: Space.Color.WHITE, space: (j, i))
                }
                space.position = positionOnBoard(j, y: i)
                addChild(space)
                spaceRow.append(space)
            }
            pieces.append(pieceRow)
            spaces.append(spaceRow)
        }
        reset()
    }
    
    func enPassant(turn: GamePiece.Side, square: Int?) {
        if square != nil && square > -1 {
            var piece: Piece
            if turn == GamePiece.Side.BLACK {
                let space = locate(square! - 16)
                piece = pieces[space.0][space.1]!
            } else {
                let space = locate(square! + 16)
                piece = pieces[space.0][space.1]!
            }
            piece.removeFromParent()
        }
    }
    
    func promotePawn(side: GamePiece.Side, square: Int, promotionPiece: GamePiece.Kind) {
        let space = locate(square - 16)
        let piece = pieces[space.0][space.1]
        piece?.setType(promotionPiece)
    }
    
    func locate(index: Int) -> (Int, Int) {
        let x: Int = index % 16
        let y: Int = 7 - (index / 16)
        return (x, y)
    }
    
    func get(position: Int) -> Space {
        let space = locate(position)
        return spaces[space.1][space.0]
    }
    
    func get(position: (Int, Int)) -> Space {
        return spaces[position.1][position.0]
    }
    
    func closestSpace(piece: Piece) -> (Int, Int) {
        let x = min(max(piece.position.x, HALF_SPACE_WIDTH), FULL_BOARD_WIDTH)
        let y = min(max(piece.position.y, HALF_SPACE_WIDTH), FULL_BOARD_WIDTH)
        
        let roundedX = SPACE_WIDTH * ceil(x / SPACE_WIDTH) - HALF_SPACE_WIDTH
        let roundedY = SPACE_WIDTH * ceil(y / SPACE_WIDTH) - HALF_SPACE_WIDTH
        
        let pt = CGPoint(x: roundedX, y: roundedY)
        return pointToSpace(pt)
    }
    
    func makeMove(move: GameMove) {
        let fromIndex = (move.fromIndex % 16, 7 - move.fromIndex / 16)
        if let spritePiece = pieces[fromIndex.0][fromIndex.1] {
            makeMove(spritePiece, move: move)
        }
    }
    
    func makeMove(piece: Piece, move: GameMove) {
        // remove piece from pieces array
        pieces[piece.boardSpace.0][piece.boardSpace.1] = nil
        
        // Check for capture
        let toIndex = (move.toIndex % 16, 7 - move.toIndex / 16)
        let pieceAtSpace = pieces[toIndex.0][toIndex.1]
        if pieceAtSpace != nil && pieceAtSpace != piece {
            pieceAtSpace!.removeFromParent()
        }
        
        // set piece at new location
        pieces[toIndex.0][toIndex.1] = piece
        piece.setSpace(toIndex.0, y: toIndex.1)
        
        
        if move.flag == GameMove.Flag.EN_PASSANT {
            enPassant(move.side, square: move.epSquare)
        } else if move.flag == GameMove.Flag.PAWN_PROMOTION
               && move.flag == GameMove.Flag.PAWN_PROMOTION_CAPTURE {
                promotePawn(move.side, square:move.toIndex, promotionPiece:move.promotionPiece!)
        }
    }
    
    func snapback(piece: Piece) {
        piece.setSpace(piece.boardSpace.0, y: piece.boardSpace.1)
    }
    
    func clearBoard(){
        for row in pieces {
            for piece in row {
                piece?.removeFromParent()
            }
        }
    }
    
    func reset() {
        self.clearBoard()
        self.updateFromFEN(DEFAULT_POSITION)
    }
    
    func pointToSpace(pt: CGPoint) -> (Int, Int) {
        let x = (Int)((pt.x - SPACE_WIDTH/2) / SPACE_WIDTH)
        let y = (Int)((pt.y - SPACE_WIDTH/2) / SPACE_WIDTH)
        return (x, y)
    }
    
    func positionOnBoard(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: CGFloat(x) * SPACE_WIDTH + HALF_SPACE_WIDTH,
                       y: CGFloat(y) * SPACE_WIDTH + HALF_SPACE_WIDTH)
    }
    
    func loadPositionFromFEN(fenString: String){
        // 0 - describes the board position by rank
        let fenParameters = fenString.componentsSeparatedByString(" ")
        let ranks = fenParameters[0].componentsSeparatedByString("/")
        var i = 0
        var j = 7
        for rank in ranks {
            for c in rank.characters {
                switch c {
                    case "p":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type: Piece.Type.PAWN, space: (i, j))
                    case "P":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type:Piece.Type.PAWN, space: (i, j))
                    case "r":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type: Piece.Type.ROOK, space: (i, j))
                    case "R":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type:Piece.Type.ROOK, space: (i, j))
                    case "n":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type:Piece.Type.KNIGHT, space: (i, j))
                    case "N":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type:Piece.Type.KNIGHT, space: (i, j))
                    case "b":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type:Piece.Type.BISHOP, space: (i, j))
                    case "B":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type:Piece.Type.BISHOP, space: (i, j))
                    case "k":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type:Piece.Type.KING, space: (i, j))
                    case "K":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type:Piece.Type.KING, space: (i, j))
                    case "q":
                        self.pieces[i++][j] = Piece(side: Piece.Side.BLACK, type:Piece.Type.QUEEN, space: (i, j))
                    case "Q":
                        self.pieces[i++][j] = Piece(side: Piece.Side.WHITE, type: Piece.Type.QUEEN, space: (i, j))
                    default:
                        let tempString = String(c)
                        if let numOfBlankSpaces = Int(tempString) {
                            for _ in 1...numOfBlankSpaces {
                                self.pieces[i++][j] = nil
                            }
                        }
                }
                if(i == 8){
                    j--
                    i = 0
                }
            }
        }
    }
    
    func updateFromFEN(fenString: String){
        loadPositionFromFEN(fenString)
        syncDisplay()
    }
    
    func syncDisplay(){
        clearBoard()
        for i in 0...7 {
            for j in 0...7 {
                if let piece = pieces[i][j] {
                    piece.setSpace(i, y: j)
                    addChild(piece)
                }
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pgnMove(moveString: String){
//        let move = moveString.componentsSeparatedByString("-")
//        let startString = move[0]
//        let endString = move[1]
    }
}
