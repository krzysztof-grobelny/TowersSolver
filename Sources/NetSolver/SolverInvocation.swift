class SolverInvocation {
    var steps: [NetSolverStep] = []
    var grid: Grid
    var metadata: GridMetadata
    var isValid = true
    
    init(grid: Grid) {
        self.grid = grid
        self.metadata = GridMetadata(forGrid: grid)
    }
    
    /// Apply all currently enqueued solver steps
    func apply() -> SolverInvocationResult {
        while !steps.isEmpty && isValid {
            let step = steps.removeFirst()
            
            let actions = step.apply(on: grid, delegate: self)
            grid = performGridActions(actions, grid: grid)
        }
        
        let state: ResultState
        
        if isValid {
            state = NetGridController(grid: grid).isSolved ? .solved : .unsolved
        } else {
            state = .invalid
        }
        
        return SolverInvocationResult(state: state, grid: grid)
    }
    
    func performGridActions(_ actions: [GridAction], grid: Grid) -> Grid {
        var grid = grid
        
        for action in actions {
            grid = performGridAction(action, grid: grid)
        }
        
        return grid
    }
    
    func performGridAction(_ action: GridAction, grid: Grid) -> Grid {
        return grid
    }
    
    struct SolverInvocationResult {
        var state: ResultState
        var grid: Grid
    }
    
    enum ResultState {
        case solved
        case unsolved
        case invalid
    }
}

extension SolverInvocation: NetSolverDelegate {
    func markIsInvalid() {
        isValid = false
    }
    
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
    
    func unavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        // Start with barriers
        var unavailable = grid.barriersForTile(atColumn: column, row: row)
        
        // Check surrounding tiles for guaranteed unavailabilities and tiles that
        // are locked while facing away the requested tile
        let surrounding = EdgePort.allCases.filter { edgePort in
            let neighborCoordinates = grid.columnRowByMoving(column: column, row: row, direction: edgePort)
            
            // Edge port that points from the neighbor tile back to the queried
            // tile
            let backEdgePort = edgePort.opposite
            
            // Check locked tiles that face away from the tile
            let neighbor = grid[row: neighborCoordinates.row, column: neighborCoordinates.column]
            if neighbor.isLocked && !neighbor.ports.contains(backEdgePort) {
                return true
            }
            // Check guaranteed unavailable back ports from available orientations
            if metadata.guaranteedUnavailablePorts(column: neighborCoordinates.column, row: neighborCoordinates.row).contains(backEdgePort) {
                return true
            }
            
            return false
        }
        
        unavailable.formUnion(surrounding)
        
        return unavailable
    }
}