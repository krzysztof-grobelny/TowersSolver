import XCTest
@testable import LoopySolver

class LoopyGreatHexagonGridGeneratorTests: XCTestCase {
    
    func testGenerate() {
        let sut = LoopyGreatHexagonGridGenerator(width: 3, height: 3)
        sut.setHint(faceIndex: 0, hint: 2)
        sut.setHint(faceIndex: 7, hint: 3)
        sut.setHint(faceIndex: 9, hint: 2)
        
        let grid = sut.generate()
        
        LoopyGridPrinter(bufferWidth: 90, bufferHeight: 60).printGrid(grid: grid)
    }
    
    func testFaceCount() {
        let makeCount = LoopyGreatHexagonGridGenerator.faceCountForGrid
        
        // Basic tests
        XCTAssertEqual(makeCount(0, 0), 0)
        XCTAssertEqual(makeCount(1, 0), 0)
        XCTAssertEqual(makeCount(1, 1), 1)
        XCTAssertEqual(makeCount(2, 1), 3)
        XCTAssertEqual(makeCount(2, 2), 11)
        XCTAssertEqual(makeCount(3, 2), 19)
        XCTAssertEqual(makeCount(3, 3), 33)
        XCTAssertEqual(makeCount(2, 3), 19)
        XCTAssertEqual(makeCount(4, 3), 47)
        XCTAssertEqual(makeCount(4, 5), 87)
        
        // Wide-range tests
        var sizes: [Int] = []
        
        for h in 4..<10 {
            for w in 4..<10 {
                sizes.append(makeCount(w, h))
            }
        }
        
        XCTAssertEqual(sizes, [67, 87, 107, 127, 147, 167, 87, 113, 139, 165,
                               191, 217, 107, 139, 171, 203, 235, 267, 127,
                               165, 203, 241, 279, 317, 147, 191, 235, 279,
                               323, 367, 167, 217, 267, 317, 367, 417])
    }
}
