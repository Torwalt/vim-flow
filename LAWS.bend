import Base
import ./src/core/scene.bend as Scene

# Every baseline cell renders as exactly one textual grid character.
law one_character_per_cell:
  for value: Scene.Cell
  {String.length(Scene.glyph(value)) == 1n : Nat}
