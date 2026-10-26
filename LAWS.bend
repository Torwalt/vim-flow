import Base
import ./src/core/scene.bend as Scene
import ./spec/navigation/model.bend as NavigationModel
import ./spec/navigation/axis.bend as NavigationAxis
import ./spec/navigation/words.bend as NavigationWords
import ./spec/navigation/lines.bend as NavigationLines
import ./spec/navigation/find.bend as NavigationFind
import ./spec/navigation/input.bend as NavigationInput
import ./spec/navigation/ALL.bend as Navigation

# The approved navigation obligations are frozen in spec/navigation/ALL.bend.
# The model, axis, words, lines, find and input modules are active, and the
# complete contract is imported as Navigation.
# Completion requires passing just contract-complete as well as just verify.

# Every baseline cell renders as exactly one textual grid character.
law one_character_per_cell:
  for value: Scene.Cell
  {String.length(Scene.glyph(value)) == 1n : Nat}
