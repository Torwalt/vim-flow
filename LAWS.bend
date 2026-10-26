import Base
import ./src/core/scene.bend as Scene
import ./spec/navigation/model.bend as NavigationModel
import ./spec/navigation/axis.bend as NavigationAxis
import ./spec/navigation/words.bend as NavigationWords

# The approved navigation obligations are frozen in spec/navigation/ALL.bend.
# The Ploopy pass activates each unchanged module here as it implements it;
# the model, axis and words modules are active, and later units add the remaining ones.
# Completion requires importing ALL as Navigation and passing just contract-complete.

# Every baseline cell renders as exactly one textual grid character.
law one_character_per_cell:
  for value: Scene.Cell
  {String.length(Scene.glyph(value)) == 1n : Nat}
