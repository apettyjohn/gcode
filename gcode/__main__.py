"""CLI entry point: python -m gcode"""

from gcode.agent import gcode

if __name__ == "__main__":
    gcode.cli_app(stream=True)
