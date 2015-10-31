//
//  board.swift
//  ChessAI
//
//  Created by Liam Cain on 10/26/15.
//  Copyright © 2015 Pillowfort Architects. All rights reserved.
//

import SpriteKit

class Board: SKNode {
    
    var pieces: [[Piece?]] = [[Piece?]]()
    
    override init() {
        super.init()
        
        for i in 0...7 {
            var row = Array<Piece?>()
            for j in 0...7 {
                row.append(nil)
                let space = SKSpriteNode(imageNamed: "board-space")
                space.position = CGPoint(x:100*j+50, y:100*i+50)
                if (i + j) % 2 == 0 {
                    space.colorBlendFactor = 1.0
                    space.color = SKColor.redColor()
                    space.zPosition = ZPOSITION_BOARD_SPACE
                }
                addChild(space)
            }
            pieces.append(row)
        }
        reset()
    }
    
    func snapToSpace(piece: Piece) {
        let x = min(max(piece.position.x, SPACE_WIDTH/2), SPACE_WIDTH*8)
        let y = min(max(piece.position.y, SPACE_WIDTH/2), SPACE_WIDTH*8)
        
        let roundedX = SPACE_WIDTH * ceil(x / SPACE_WIDTH) - SPACE_WIDTH/2
        let roundedY = SPACE_WIDTH * ceil(y / SPACE_WIDTH) - SPACE_WIDTH/2
        
        let pt = CGPoint(x: roundedX, y: roundedY)
        let space = pointToSpace(pt)
        
        let pieceAtSpace = pieces[space.0][space.1]
        if pieceAtSpace != nil && pieceAtSpace != piece {
            pieceAtSpace?.removeFromParent()
        }
        
        pieces[space.0][space.1] = piece
        piece.position = pt
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
        self.updateFromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }
    
    func pointToSpace(pt: CGPoint) -> (Int, Int) {
        let x = (Int)((pt.x - SPACE_WIDTH/2) / SPACE_WIDTH)
        let y = (Int)((pt.y - SPACE_WIDTH/2) / SPACE_WIDTH)
        return (x, y)
    }
    
    func positionOnBoard(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: x * 100 + 50, y: y * 100 + 50)
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
                    self.pieces[i++][j] = Pawn(side: Piece.Side.BLACK)
                case "P":
                    self.pieces[i++][j] = Pawn(side: Piece.Side.WHITE)
                case "r":
                    self.pieces[i++][j] = Rook(side: Piece.Side.BLACK)
                case "R":
                    self.pieces[i++][j] = Rook(side: Piece.Side.WHITE)
                case "n":
                    self.pieces[i++][j] = Knight(side: Piece.Side.BLACK)
                case "N":
                    self.pieces[i++][j] = Knight(side: Piece.Side.WHITE)
                case "b":
                    self.pieces[i++][j] = Bishop(side: Piece.Side.BLACK)
                case "B":
                    self.pieces[i++][j] = Bishop(side: Piece.Side.WHITE)
                case "k":
                    self.pieces[i++][j] = King(side: Piece.Side.BLACK)
                case "K":
                    self.pieces[i++][j] = King(side: Piece.Side.WHITE)
                case "q":
                    self.pieces[i++][j] = Queen(side: Piece.Side.BLACK)
                case "Q":
                    self.pieces[i++][j] = Queen(side: Piece.Side.WHITE)
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
        self.loadPositionFromFEN(fenString)
        self.syncDisplay()
    }
    
    func syncDisplay(){
        self.clearBoard()
        for i in 0...7 {
            for j in 0...7 {
                if let piece = pieces[i][j] {
                    piece.position = positionOnBoard(i, y: j)
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
