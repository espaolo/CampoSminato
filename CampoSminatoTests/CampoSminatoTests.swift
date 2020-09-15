//
//  CampoSminatoTests.swift
//  CampoSminatoTests
//
//  Created by Paolo Esposito on 10/09/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import XCTest
@testable import CampoSminato

class CampoSminatoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    // MARK: - Field Init Test
    
    func testBoardSize() {
        
        // Init a game field 8x8, we check for the correct size
        let field = Field.init(width: 8, height: 8)
        
        // Field exists
        XCTAssertNotNil(field)
        
        // It's a board with size 8x8
        XCTAssertTrue(field.height == 8)
        XCTAssertTrue(field.width == 8)
    }
    
    // MARK: - Field Cells Test

    func testUnknownCells() {
        // Init a game field 8x8, we check the number of remaing cells
        let field = Field.init(width: 8, height: 8)
        
        // For a fresh 8x8 board remaining cells must be 64
        XCTAssertTrue(field.remainingCells == 64)
        
        // No bombs were dropped
        XCTAssertTrue(field.numberOfBombs == 0)
        
    }
    // MARK: - Bomb Cells Test

    func testZeroBomb() {
        // Init a game field 8x8, we check the number of remaing cells
        let field = Field.init(width: 8, height: 8)
        
        // For a fresh 8x8 board no bomb were dropped
        XCTAssertTrue(field.numberOfBombs == 0)
    }
    
    func testDropTheBomb() {
        // Init a game field 8x8, we check the number of remaing cells
        let field = Field.init(width: 5, height: 5)
        // Insert a bomb
        field.insertBombs(1)
        
        // We got one bomb, not two
        XCTAssertTrue(field.numberOfBombs == 1)
        XCTAssertFalse(field.numberOfBombs == 2)
    }

    

}
