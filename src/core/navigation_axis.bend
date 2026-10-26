import Base
import ../../spec/navigation/axis.bend as Axis
import ../../spec/navigation/model.bend as Model

def move_impl(+position: Nat, direction: Axis.Direction, count: Nat) -> Nat:
  match direction:
    case Axis.Left{}:
      Model.index(Model.row(position), Nat.sub(Model.column(position), count))
    case Axis.Down{}:
      Model.index(Nat.min(19n, Nat.add(Model.row(position), count)), Model.column(position))
    case Axis.Up{}:
      Model.index(Nat.sub(Model.row(position), count), Model.column(position))
    case Axis.Right{}:
      Model.index(Model.row(position), Nat.min(39n, Nat.add(Model.column(position), count)))

def Axis.move(position, direction, count):
  move_impl(position, direction, count)
