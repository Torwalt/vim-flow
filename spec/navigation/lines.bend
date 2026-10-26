import Base
import ./model.bend as M

type Motion is Data:
  ColumnZero{}
  FirstNonblank{}
  RowEnd{}
  FirstRow{}
  LastRow{}

law move:
  for field: M.Field
  for position: Nat
  for motion: Motion
  for count: Nat
  Nat

def target_row(+p: Nat, motion: Motion, +n: Nat) -> Nat:
  match motion:
    case ColumnZero{}:
      M.row(p)
    case FirstNonblank{}:
      M.row(p)
    case RowEnd{}:
      Nat.min(19n, Nat.add(M.row(p), Nat.sub(M.effective(n), 1n)))
    case FirstRow{}:
      Nat.min(19n, Nat.sub(n, 1n))
    case LastRow{}:
      Nat.min(19n, Nat.sub(Nat.add(n, Nat.mul(20n, M.bit(Nat.is_eq(n, 0n)))), 1n))

def nonblank(+text: String, +r: Nat, +p: Nat) -> Bool:
  Bool.and(M.inside(p), Bool.and(Nat.is_eq(M.row(p), r),
    Bool.not(Char.is_eq(M.text_at(text, p), ' '))))

def IndentSelected(+text: String, +r: Nat, +out: Nat) -> Type:
  {Bool.and(M.inside(out), Bool.and(Nat.is_eq(M.row(out), r),
    Bool.or(nonblank(text, r, out), Nat.is_eq(M.column(out), 0n)))) == True{} : Bool}
  & (@+q: Nat -> {Bool.or(Bool.not(nonblank(text, r, q)),
    Bool.and(nonblank(text, r, out), Nat.is_le(out, q))) == True{} : Bool})

law zero_column:
  for f: M.Field
  for +p: Nat
  for n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(f, p, ColumnZero{}, n) == M.index(M.row(p), 0n) : Nat}

law row_end:
  for f: M.Field
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(f, p, RowEnd{}, n) == M.index(target_row(p, RowEnd{}, n), 39n) : Nat}

law first_nonblank:
  for +f: M.Field
  for +p: Nat
  for n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  IndentSelected(M.contents(f), M.row(p), move(f, p, FirstNonblank{}, n))

law first_row:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  IndentSelected(M.contents(f), target_row(p, FirstRow{}, n), move(f, p, FirstRow{}, n))

law last_row:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  IndentSelected(M.contents(f), target_row(p, LastRow{}, n), move(f, p, LastRow{}, n))

law bounded:
  for f: M.Field
  for +p: Nat
  for m: Motion
  for n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {M.inside(move(f, p, m, n)) == True{} : Bool}
