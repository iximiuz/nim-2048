import field

type
    Game* = ref GameObj
    GameObj = object
        field*: Field
        score*: int

method addStartTiles(self: Game, nStartTiles: int) {.base.} =
    for _ in 0..<nStartTiles:
        self.field.addRandomTile()
        self.field.resetLastAdded()

method cellCoords(self: Game, x, y: int, rotated: bool = true): Coords {.base.} =
    result = (x: if rotated: y else: x, y: if rotated: x else: y)

method move(self: Game, direction: char) {.base.} =
    assert "lrud".contains(direction)
    var rotated = "ud".contains(direction)
    var rowsCount = if not rotated: self.field.h else: self.field.w
    var colsCount = if not rotated: self.field.w else: self.field.h
    var xStart = 0
    var xEnd = colsCount - 1
    var offset = 1
    if "rd".contains(direction):
        swap(xStart, xEnd)
        offset = -offset

    proc shift(rowNo: int): bool =
        var x = xStart
        var skip = 0
        var shifted = false
        while 0 < abs(x - xEnd):
            x += offset
            var ct = self.cellCoords(xStart + skip, rowNo, rotated)
            var cf = self.cellCoords(x, rowNo, rotated)
            if 0 == self.field[ct]:
                self.field[ct] = self.field[cf]
                shifted = shifted or 0 != self.field[cf]
                self.field[cf] = 0
            if 0 != self.field[ct]:
                skip += offset
        result = shifted

    proc merge(rowNo: int): bool =
        var x = xStart
        var merged = false
        while 0 <= x and x < colsCount and 0 <= x + offset and x + offset <
                colsCount and 0 != self.field[self.cellCoords(x, rowNo, rotated)]:
            var ct = self.cellCoords(x, rowNo, rotated)
            var cf = self.cellCoords(x + offset, rowNo, rotated)
            if 0 == self.field[ct] or self.field[ct] == self.field[cf]:
                self.field[ct] = self.field[ct] + self.field[cf]
                self.score += self.field[ct]
                self.field[cf] = 0
                x += offset
                merged = true
            x += offset
        result = merged

    var shiftedOrMerged = false
    for y in 0..<colsCount:
        if shift(y): shiftedOrMerged = true
        if merge(y): shiftedOrMerged = true
        if shift(y): shiftedOrMerged = true

    if shiftedOrMerged:
        self.field.addRandomTile()
    else:
        self.field.resetLastAdded()

method reset(self: Game) {.base.} =
    self.field.reset()
    self.score = 0

method left*(self: Game) {.base.} =
    self.move('l')

method right*(self: Game) {.base.} =
    self.move('r')

method up*(self: Game) {.base.} =
    self.move('u')

method down*(self: Game) {.base.} =
    self.move('d')

method restart*(self: Game, nStartTiles: int = 2) {.base.} =
    self.reset()
    self.addStartTiles(nStartTiles)

method isWon*(self: Game): bool {.base.} =
    for row in self.field:
        for c in row:
            if c >= 2048:
                return true
    result = false

proc newGame*(w: int = 4, h: int = 4, nStartTiles: int = 2): Game =
    result = Game(field: newField(w, h), score: 0)
    result.addStartTiles(nStartTiles)

