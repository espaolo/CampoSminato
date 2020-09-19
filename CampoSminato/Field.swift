//
//  Field.swift
//  CampoSminato
//
//  Created by Paolo Esposito on 10/09/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import Foundation

class Field: NSObject {
    
    //  The size of the board
    var width: Int = 0
    var height: Int = 0
    
    //  The number of bombs inside the field
    var numberOfBombs: Int = 0
    //  The number of remaining unknown cells excluding bombs
    var remainingCells: Int = 0
    //  Array of IndexPath with the coordinate of the bombs
    var bombCells: [IndexPath] = [IndexPath]()
    
    var matrix: [[BoardCell?]] = [[BoardCell?]]()
    
    //  The Board Delegates.
    weak var delegate: BoardDelegate?
    
    // Position Mask for main directions
    struct PositionMask : OptionSet {
        let  rawValue: Int
        static let North = 1 << 0
        static let South = 1 << 1
        static let West = 1 << 2
        static let East = 1 << 3
    }
    
    
    // Init the Field and assign a Matrix of cells unknowned
    init(width: Int, height: Int) {
        super.init()
        matrix = [[BoardCell?]]()
        self.height = height
        self.width = width
        self.remainingCells = width * height
        
        var tempMatrix: [[BoardCell?]] = []
        
        for i in 0..<height {
            tempMatrix.append( [] )
            for j in 0..<width {
                let indexArr = [i, j]
                let ip = IndexPath(indexes: indexArr)
                tempMatrix[i].append(BoardCell(positionInBoard: ip))
            }
        }
        matrix = tempMatrix
    }
    
    
    
    func setRemainingCells(_ remainingCells: Int) {
        self.remainingCells = remainingCells
        if remainingCells == 0 {
            delegate!.willWin()
            NotificationCenter.default.post(name: NSNotification.Name("UserWinNotification"), object: nil)
        }
    }
    
    func insertBombs(_ bombs: Int) {
        numberOfBombs = bombs
        self.remainingCells = remainingCells - bombs
        var toInsert = bombs // number of bombs to insert
        
        while toInsert != 0 {
            let x = Int(arc4random_uniform(UInt32(width - 1)))  // random x position
            let y = Int(arc4random_uniform(UInt32(height - 1))) // random y position
            let indexArr = [x, y] // random cell
            
            let indexPath = IndexPath(indexes: indexArr)
            
            //let aCell = BoardCell.init(positionInBoard: indexPath)
            let aCell = boardCell(at: indexPath)
            
            if aCell?.isBomb() == false {
                aCell?.status = BoardCell.BoardCellStatus.cellBomb
                // Increase adiacent cells in 8-neighborhood
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.North), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.South), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.West), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.East), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.North | PositionMask.East), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.North | PositionMask.West), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.South | PositionMask.East), respectTo: aCell)?.increaseAdiacentBombs()
                cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.South | PositionMask.West), respectTo: aCell)?.increaseAdiacentBombs()
                bombCells.append(indexPath)
                toInsert -= 1
                
            }
        }
    }
    
    func boardCell(at indexPath: IndexPath?) -> BoardCell? {
        let cell = matrix[indexPath?.section ?? 0][indexPath?.row ?? 0]
        return cell
    }
    
    func cell(atPostionMask position: PositionMask, respectTo cell: BoardCell?) -> BoardCell? {
        let positionIndex = cell?.positionInBoard
        var x = positionIndex?.section ?? 0
        var y = positionIndex?.row ?? 0
        
        if (position.rawValue & PositionMask.North) != 0 {
            y -= 1
        }
        if position.rawValue & PositionMask.South != 0  {
            y += 1
        }
        if position.rawValue & PositionMask.East != 0  {
            x += 1
        }
        if position.rawValue & PositionMask.West != 0  {
            x -= 1
        }
        var result : BoardCell
        
        if (x >= 0 && x < width) && (y >= 0 && y < height) {
            result = matrix[x][y]! // Flood to check.
            return result
        }
        else { // Cancels if the index is out of bounds.
            return nil
        }
    }
    
    func tapCellAtIndexPath(path: IndexPath){
        //User tap events
        
        let selectedCell = boardCell(at: path)
        expandFill(selectedCell)
        
        if (selectedCell?.status == BoardCell.BoardCellStatus.cellBomb){
            self.delegate?.userFindBomb(at: path)
            self.delegate?.willLose()
            
            NotificationCenter.default.post(name: NSNotification.Name("UserLoseNotification"), object: nil)

        }else if(selectedCell?.status == BoardCell.BoardCellStatus.cellUnknown){
            selectedCell?.status = BoardCell.BoardCellStatus.cellUncovered
            self.delegate?.boardCell(selectedCell, didBecomeDiscoveredAt: path)
        }
    }

    
    // Expand uncovered cells along main directions
    // Core recursive Algorithm for MineSweeper:
    // You start at some position in a 2D Grid [x,y], then look in all directions and fill them if you can
    // If (x,y) can't be filled, return.
    func expandFill(_ startingCell: BoardCell?) {
        if let test = startingCell{
        if (startingCell!.isFillable()) {
            setRemainingCells(remainingCells - 1)
            startingCell?.status = BoardCell.BoardCellStatus.cellUncovered
            delegate!.boardCell(startingCell, didBecomeDiscoveredAt: startingCell!.positionInBoard)
            if startingCell?.adiacentBombs == 0 {
                expandFill(cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.North), respectTo: startingCell))
                expandFill(cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.South), respectTo: startingCell))
                expandFill(cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.West), respectTo: startingCell))
                expandFill(cell(atPostionMask: Field.PositionMask(rawValue: PositionMask.East), respectTo: startingCell))
            } else {
                // adiacent bombs
                return
            }
        } else {
            // isAbomb or already seen
            return
            }
        }
    }
}


extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



protocol BoardDelegate: NSObjectProtocol {
    //  This method tells to the delegate that some cell has just been discovered and should become visible in the interface
    //
    //  - Parameters:
    //    - cell:      The cell just discovered
    //    - indexPath: The indexPath of the cell
    func boardCell(_ cell: BoardCell?, didBecomeDiscoveredAt indexPath: IndexPath?)
    //  Called when the user tap a bomb.
    //
    //  - Parameter indexPath: The position of the bomb.
    func userFindBomb(at indexPath: IndexPath?)
    
    //  Called when the user win
    func willWin()
    
    //  Called when the user lose
    func willLose()
}



class BoardCell: NSObject {
    
    enum BoardCellStatus {
        case cellUnknown // Not yet discoverd
        case cellUncovered // Uncovered
        case cellBomb
    }
    
    //  The status of the cell
    var status: BoardCellStatus?
    //  The number of adiacentBombs in all directions
    var adiacentBombs = 0
    //  The position of the cell in the board
    var positionInBoard: IndexPath? = [0,0]
    
    //  Create a new cell with given parameters
    //
    //  - Parameter position: The position of the cell
    //
    //  - Returns: Return a new cell with a given position and an cellUnknown status
    init(positionInBoard position: IndexPath?) {
        super.init()
        positionInBoard = position
        adiacentBombs = 0
        status = BoardCellStatus.cellUnknown
    }
    //  Increase the number of adiacentBombs of 1.
    func increaseAdiacentBombs() {
        self.adiacentBombs += 1
    }
    
    //  Return if the current cell contains a bombs
    //
    //  - Returns: Return YES if the cell contains one bomb, NO otherwise
    func isBomb() -> Bool {
        return self.status == BoardCellStatus.cellBomb ? true : false
    }
    
    func isFillable() -> Bool {
        if isBomb() {
            return false
        }
        if self.status != BoardCellStatus.cellUnknown {
            return false
        }
        return true
    }
    
    
}
