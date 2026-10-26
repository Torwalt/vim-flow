import Base

type Cell is Data:
  Floor{}
  Wall{}

def columns() -> U32:
  40

def rows() -> U32:
  20

def cell(+column: U32, +row: U32) -> Cell:
  match column row:
    case 0 _:
      Wall{}
    case 39 _:
      Wall{}
    case _ 0:
      Wall{}
    case _ 19:
      Wall{}
    case _ _:
      Floor{}

def glyph(value: Cell) -> String:
  match value:
    case Floor{}:
      "."
    case Wall{}:
      "#"
