import curses
import signal
import socket
import sys
from time import sleep

DEFAULT_PORT = 12321

COMMAND_LEFT = 0
COMMAND_RIGHT = 1
COMMAND_UP = 2
COMMAND_DOWN = 3
COMMAND_RESTART = 4
COMMAND_EXIT = 100
COMMAND_HELP = 101
COMMAND_UNKNOWN = 110


def init_curses():
    stdscr = curses.initscr()
    curses.noecho()
    curses.cbreak()
    stdscr.keypad(1)
    return stdscr


def exit_curses(screen):
    curses.nocbreak()
    screen.keypad(0)
    curses.echo()
    curses.endwin()


def print_str(line, screen):
    screen.clear()
    screen.addstr(0, 0, line + "\n")
    screen.refresh()


def _help(screen):
    help_str = (
        "************************************************"
        "\n* (LEFT, RIGHT, UP, DOWN) arrow keys - playing *"
        "\n* 'R' - restart game                           *"
        "\n* ESC or 'Q' - exit game (and close client)    *"
        "\n* 'H' - show this message                      *"
        "\n************************************************"
    )
    print_str(help_str, screen)


def read_command():
    c = stdscr.getch()
    arrow_codes = {
        curses.KEY_LEFT: COMMAND_LEFT,
        curses.KEY_RIGHT: COMMAND_RIGHT,
        curses.KEY_UP: COMMAND_UP,
        curses.KEY_DOWN: COMMAND_DOWN,
    }
    if c in arrow_codes:
        return arrow_codes[c]

    exit_codes = tuple(map(ord, (chr(27), "q", "Q")))
    help_codes = tuple(map(ord, ("h", "H")))
    restart_codes = tuple(map(ord, ("r", "R")))
    other_codes = {
        exit_codes: COMMAND_EXIT,
        help_codes: COMMAND_HELP,
        restart_codes: COMMAND_RESTART,
    }
    for codes in other_codes:
        if c in codes:
            return other_codes[codes]
    return COMMAND_UNKNOWN


def send_command(sock, command, screen):
    messages = {
        COMMAND_LEFT: "LEFT",
        COMMAND_RIGHT: "RIGHT",
        COMMAND_UP: "UP",
        COMMAND_DOWN: "DOWN",
        COMMAND_RESTART: "RESTART...",
        COMMAND_EXIT: "EXIT...",
    }
    commands = {
        COMMAND_LEFT: 0,
        COMMAND_RIGHT: 1,
        COMMAND_UP: 2,
        COMMAND_DOWN: 3,
        COMMAND_RESTART: 4,
        COMMAND_EXIT: 9,
    }
    print_str(messages[command], screen)
    sock.send(str(commands[command]).encode())


def sig_handler(frame, signal):
    sys.exit("Good bye!")


if __name__ == "__main__":
    signal.signal(signal.SIGINT, sig_handler)

    stdscr = init_curses()
    try:
        sock = socket.socket()
        port = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PORT
        sock.connect(("localhost", port))
        _help(stdscr)
        while True:
            command = read_command()
            if command == COMMAND_HELP:
                _help(stdscr)
            elif command == COMMAND_UNKNOWN:
                print_str("Unexpected input. Press 'H' for help.", stdscr)
            else:
                send_command(sock, command, stdscr)
                if command == COMMAND_EXIT:
                    sleep(0.5)
                    break
        sock.close()
    finally:
        exit_curses(stdscr)
