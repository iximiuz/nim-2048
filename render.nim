import strutils
import field, game

proc renderField*(field: Field) =
    proc pickColor(v: int, isLastAdded: bool): string =
        if isLastAdded:
            result = "\27[7;1;34m" # blue
        else:
            result = case v:
            of 0:
                ""          # default
            of 2..16:
                "\27[7;1;37m" # gray
            of 32..256:
                "\27[7;1;32m" # green
            of 512..1024:
                "\27[7;1;33m" # yellow
            else:
                "\27[7;1;31m" # red
            
    proc pickValue(v: int): string =
        var vstr = v.intToStr
        result = case v:
        of 0:
            "        "
        of 2..8:
            "   " & vstr & "    "
        of 16..64:
            "   " & vstr & "   "
        of 128..512:
            "  " & vstr & "   "
        else:
            "  " & vstr & "  "         

    proc drawRow(row: seq[int], y: int, lastAdded: Coords) =
        type 
            Lines = array[3, string]
            
        var lines: Lines
        var counter = 0
        for x, v in row:
            for r in 0..2:
                if 0 == counter:
                    lines[r] = "|"

                var isLastAdded = x == lastAdded.x and y == lastAdded.y
                lines[r] &= pickColor(v, isLastAdded)
                lines[r] &= (if 1 == r: pickValue(v) else: "        ")
                lines[r] &= "\27[0m|"

            inc counter

        for s in items(lines):
            echo s

    echo " " & "_________".repeat(field.w)[0 .. ^2] & " "
    for y, row in field:
        drawRow(row, y, field.lastAdded)
        if y < field.h - 1:
            echo "|" & "--------|".repeat(field.w)
    echo " " & "¯¯¯¯¯¯¯¯¯".repeat(field.w)[0 .. ^3] & " "

proc render*(game: Game) =
    echo "\27c"  # clear screen
    echo "Score: " & game.score.intToStr & (if game.isWon(): " [Victory!]" else: "")
    renderField(game.field)
    