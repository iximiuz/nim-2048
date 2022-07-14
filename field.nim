import random

type
    Coords* = tuple[x: int, y: int]
    Field* = ref FieldObj
    FieldObj = object
        cells: seq[seq[int]]
        w*, h*: int
        lastAdded*: Coords

const InvalidCoord: Coords = (x: -1, y: -1)

proc newField*(w, h: int): Field =
    var grid = newSeq[seq[int]](h)
    for i in 0..<h:
        grid[i] = newSeq[int](w)
    Field(w: w, h: h, cells: grid, lastAdded: InvalidCoord)

iterator items*(self: Field): seq[int] =
    for y in 0..<self.h:
        yield self.cells[y]

iterator pairs*(self: Field): tuple[y: int, row: seq[int]] =
    for y in 0..<self.h:
        yield (y, self.cells[y])

method getRandomEmptyCell(self: Field): Coords {.base.} =
    var emptyCells = newSeq[Coords](0)
    for y in 0..<self.h:
        for x in 0..<self.w:
            if 0 == self.cells[y][x]:
                emptyCells.add((x: x, y: y))
    result = if emptyCells.len > 0: sample(emptyCells) else: InvalidCoord

method `[]`*(self: Field, coord: Coords): int {.base.} =
    self.cells[coord.y][coord.x]

method `[]=`*(self: Field, coord: Coords, val: int) {.base.} =
    self.cells[coord.y][coord.x] = val

method addRandomTile*(self: Field) {.base.} =
    randomize()
    var cellCoord = getRandomEmptyCell(self)
    if cellCoord != InvalidCoord:
        self[cellCoord] = if rand(1.0) < 0.9: 2 else: 4
        self.lastAdded = cellCoord

method resetLastAdded*(self: Field) {.base.} =
    self.lastAdded = InvalidCoord

method reset*(self: Field) {.base.} =
    for y in 0..<self.h:
        for x in 0..<self.w:
            self.cells[y][x] = 0
