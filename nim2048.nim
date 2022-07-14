import os, strutils, net
import render, game, input


const DefaultPort = 12321
let port = if paramCount() > 0: parseInt(paramStr(1))
          else: DefaultPort

var inputProcessor = initInputProcessor(port = Port(port))
var g = newGame()

while true:
    render(g)
    var command = inputProcessor.read()
    case command:
    of cmdRestart:
        g.restart()
    of cmdLeft:
        g.left()
    of cmdRight:
        g.right()
    of cmdUp:
        g.up()
    of cmdDown:
        g.down()
    of cmdExit:
        echo "Good bye!"
        break
