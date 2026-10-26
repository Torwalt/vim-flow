import Base
import ../../spec/navigation/lines.bend as Lines
import ../../spec/navigation/model.bend as Model
import ./navigation_model.bend as ModelImpl

def scan_first(+text: String, +r: Nat, fuel: Nat, +q: Nat, c: Bool) -> Nat:
  match fuel:
    case 0n:
      Model.index(r, 0n)
    case 1n+k:
      match c:
        case True{}:
          q
        case False{}:
          scan_first(text, r, k, Nat.add(q, 1n), Lines.nonblank(text, r, Nat.add(q, 1n)))

def first_nonblank(+text: String, +r: Nat) -> Nat:
  scan_first(text, r, 800n, 0n, Lines.nonblank(text, r, 0n))

def move_impl(+field: Model.Field, +p: Nat, motion: Lines.Motion, +n: Nat) -> Nat:
  match motion:
    case Lines.ColumnZero{}:
      Model.index(Model.row(p), 0n)
    case Lines.FirstNonblank{}:
      first_nonblank(ModelImpl.norm(800n, field), Model.row(p))
    case Lines.RowEnd{}:
      Model.index(Lines.target_row(p, Lines.RowEnd{}, n), 39n)
    case Lines.FirstRow{}:
      first_nonblank(ModelImpl.norm(800n, field),
        Lines.target_row(p, Lines.FirstRow{}, n))
    case Lines.LastRow{}:
      first_nonblank(ModelImpl.norm(800n, field),
        Lines.target_row(p, Lines.LastRow{}, n))

def Lines.move(f, p, motion, n):
  move_impl(f, p, motion, n)
