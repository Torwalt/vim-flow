import Base
import ./model.bend as M

law move:
  for field: M.Field
  for position: Nat
  for target: Char
  for right: Bool
  for count: Nat
  Nat

def toward(+p: Nat, +q: Nat, right: Bool) -> Bool:
  match right:
    case True{}:
      Nat.is_gt(q, p)
    case False{}:
      Nat.is_lt(q, p)

def within(+i: Nat, q: Nat, right: Bool) -> Bool:
  match right:
    case True{}:
      Nat.is_le(i, q)
    case False{}:
      Nat.is_ge(i, q)

def limit(right: Bool) -> Nat:
  match right:
    case True{}:
      799n
    case False{}:
      0n

def hit(+text: String, +p: Nat, +i: Nat, +target: Char, +right: Bool) -> Bool:
  Bool.and(M.inside(i), Bool.and(Nat.is_eq(M.row(i), M.row(p)),
    Bool.and(toward(p, i, right), Char.is_eq(M.text_at(text, i), target))))

# Counts matches in an interval; does not compute a movement destination.
def hits(+fuel: Nat, +text: String, +p: Nat, +q: Nat, +target: Char, +right: Bool) -> Nat:
  match fuel:
    case 0n:
      0n
    case 1n+i:
      Nat.add(M.bit(Bool.and(hit(text, p, M.index(M.row(p), i), target, right), within(M.index(M.row(p), i), q, right))),
        hits(i, text, p, q, target, right))

def selected(+text: String, +p: Nat, +target: Char, +right: Bool, +n: Nat, +out: Nat) -> Bool:
  Bool.or(
    Bool.and(Nat.is_le(n, hits(40n, text, p, limit(right), target, right)),
      Bool.and(hit(text, p, out, target, right),
        Nat.is_eq(hits(40n, text, p, out, target, right), n))),
    Bool.and(Nat.is_gt(n, hits(40n, text, p, limit(right), target, right)), Nat.is_eq(out, p)))

law zero:
  for f: M.Field
  for +p: Nat
  for target: Char
  for right: Bool
  {move(f, p, target, right, 0n) == p : Nat}

law exact:
  for +f: M.Field
  for +p: Nat
  for +target: Char
  for +right: Bool
  for +n: Nat
  for -ok: {M.inside(p) == True{} : Bool}
  {selected(M.contents(f), p, target, right, 1n+n,
    move(f, p, target, right, 1n+n)) == True{} : Bool}

law bounded:
  for f: M.Field
  for +p: Nat
  for target: Char
  for right: Bool
  for n: Nat
  for -ok: {M.inside(p) == True{} : Bool}
  {M.inside(move(f, p, target, right, n)) == True{} : Bool}
