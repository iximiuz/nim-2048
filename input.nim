import net, strutils


type
    Commands* = enum
        cmdLeft, cmdRight, cmdUp, cmdDown, cmdRestart, cmdExit = 9
    InputProcessor = object
        server, client: Socket


proc initInputProcessor*(host: string = "localhost", port: Port = Port(
        12321)): InputProcessor =
    var s = newSocket()
    s.bindAddr(port = port)
    s.listen()
    InputProcessor(server: s)

# {.experimental.}
# proc `=destroy`(self: InputProcessor) =
#     self.server.close()
#     if self.client != nil:
#         self.client.close()

method read*(self: var InputProcessor): Commands {.base.} =
    if self.client == nil:
        self.client = newSocket()
        self.server.accept(self.client)

    while true:
        var buf = r""
        if self.client.recv(buf, 1) == 0:
            return cmdExit

        var opcode = parseInt(buf)
        case opcode:
        of 0..5:
            return Commands(opcode)
        of 9:
            return Commands(opcode)
        else:
            continue

