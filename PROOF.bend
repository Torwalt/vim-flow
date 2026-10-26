import Base
import ./src/core/scene.bend as Scene
import ./LAWS.bend as Laws

def Laws.one_character_per_cell(value):
  match value:
    case Scene.Floor{}:
      {==}
    case Scene.Wall{}:
      {==}
