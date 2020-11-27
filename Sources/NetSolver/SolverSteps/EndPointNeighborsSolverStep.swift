/// Checks ports of an endpoint against other neighboring endpoints or barriers,
/// marking the tile as solved if all but one port point to a non-barrier and/or
/// non-endpoint.
struct EndPointNeighborsSolverStep: NetSolverStep {
    var column: Int
    var row: Int
    
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        let tile = grid[row: row, column: column]
        if tile.isLocked {
            return []
        }
        
        let available = Set(EdgePort.allCases).subtracting(delegate.unavailablePortsForTile(atColumn: column, row: row))
        
        // If only one of the surrounding tiles is not an endpoint, lock the
        // orientation of the tile to be that.
        let surrounding = grid.surroundingTiles(column: column, row: row)
        let nonEndPoints = surrounding.filter { available.contains($0.edge) && $0.tile.kind != .endPoint }
        if nonEndPoints.count == 1 {
            return [
                .lockOrientation(column: column, row: row, orientation: nonEndPoints[0].edge.asOrientation)
            ]
        }
        
        return []
    }
}