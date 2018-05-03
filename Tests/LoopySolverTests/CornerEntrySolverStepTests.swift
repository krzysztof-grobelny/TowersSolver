import XCTest
@testable import LoopySolver

class CornerEntrySolverStepTests: XCTestCase {
    var sut: CornerEntrySolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = CornerEntrySolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        // . _ . _ .
        // ! _ ! _ ║
        // ! _ ! 1 !
        //
        // Result should be a grid with the left, bottom, and right edges of the
        // `1` face all disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.withEdge(5) { $0.state = .marked }
        
        let result = sut.apply(to: field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `1` face
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[3], .disabled)
    }
    
    func testApplyOnFaceWithDisabledEdge() {
        // Create a simple 2x3 square grid like so:
        // . _ . _ .
        // ! _ !   ║
        // ! _ ! 1 !
        // . _ ! _ .
        //
        // Result should be a grid with the bottom and left edges of the `1` face
        // disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.withEdge(5) { $0.state = .marked }
        field.withEdge(6) { $0.state = .disabled }
        
        let result = sut.apply(to: field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `1` face
        XCTAssertEqual(edgeStatesForFace(3)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[3], .disabled)
    }
    
    func testApplyOnFaceWithLoopback() {
        // Create a simple 2x3 square grid like so:
        // . _ . _ .
        // ! _ ! _ ║
        // !   ! 1 !  <- bottom edge of `1` cell is disabled, as well.
        // .   ! _ !
        //
        // Result should be a grid with the bottom, left and right edges of the
        // `1` face disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.withEdge(5) { $0.state = .marked }
        field.withEdge(8) { $0.state = .disabled }
        field.withEdge(11) { $0.state = .disabled }
        field.withEdge(13) { $0.state = .disabled }
        
        let result = sut.apply(to: field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `1` face
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[3], .disabled)
    }
    
    func testApplyOnSemiCompleteFace() {
        // Create a simple 3x2 square grid like so:
        // . _ . _ . _ .
        // ! _ ! _ ║ _ !
        // ! _ ! 3 ! _ !
        //
        // Result should be a grid with the left and bottom edges of the `3` face
        // all marked as part of the solution, and the edge to the bottom-right
        // of the marked edge should be disabled, since the semi-complete face
        // highjacked the line path.
        let gridGen = LoopySquareGridGen(width: 3, height: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        var field = gridGen.generate()
        field.withEdge(5) { $0.state = .marked }
        
        let result = sut.apply(to: field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        
        // Top-center face
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
        // `3` face
        XCTAssertEqual(edgeStatesForFace(4)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(4)[3], .marked)
        // Bottom-right face
        XCTAssertEqual(edgeStatesForFace(5)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(5)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(5)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(5)[3], .normal)
        
        LoopyFieldPrinter(bufferWidth: 14, bufferHeight: 5).printField(field: result)
    }
}
