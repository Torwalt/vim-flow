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

# Counts matches at one row-local column at or above a lower bound. Using the
# same lower-bound interval for both directions keeps the nth rank aligned with
# the kernel scan; `selected` turns a forward prefix rank into the equivalent
# suffix rank. This is the local equivalent of the original absolute interval.
def within(+i: Nat, q: Nat) -> Bool:
  Nat.is_ge(i, q)

def limit(right: Bool) -> Nat:
  0n

def hit(+text: String, +p: Nat, +i: Nat, +target: Char, +right: Bool) -> Bool:
  Bool.and(M.inside(i), Bool.and(Nat.is_eq(M.row(i), M.row(p)),
    Bool.and(toward(p, i, right), Char.is_eq(M.text_at(text, i), target))))

# Counts matches in a row-local interval; does not compute a movement
# destination. Local column i is read through the row's index, so the interval
# is row-local even though positions are absolute.
def hits(+fuel: Nat, +text: String, +p: Nat, +q: Nat, +target: Char, +right: Bool) -> Nat:
  match fuel:
    case 0n:
      0n
    case 1n+i:
      Nat.add(M.bit(Bool.and(hit(text, p, M.index(M.row(p), i), target, right),
        within(M.index(M.row(p), i), q))),
        hits(i, text, p, q, target, right))

def total(+text: String, +p: Nat, +target: Char, +right: Bool) -> Nat:
  hits(40n, text, p, limit(right), target, right)

# Rank from the high (large-column) end. A forward find wants the nth match
# from the low end, which is the (total - n + 1)th match from the high end; a
# backward find is already counted from the high end.
def rank(right: Bool, +n: Nat, +count: Nat) -> Nat:
  match right:
    case True{}:
      Nat.add(Nat.sub(count, n), 1n)
    case False{}:
      n

def selected(+text: String, +p: Nat, +target: Char, +right: Bool, +n: Nat, +out: Nat) -> Bool:
  Bool.or(
    Bool.and(Nat.is_le(n, total(text, p, target, right)),
      Bool.and(hit(text, p, out, target, right),
        Nat.is_eq(hits(40n, text, p, out, target, right),
          rank(right, n, total(text, p, target, right))))),
    Bool.and(Nat.is_gt(n, total(text, p, target, right)), Nat.is_eq(out, p)))

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
  for ok: {M.inside(p) == True{} : Bool}
  {selected(M.contents(f), p, target, right, 1n+n,
    move(f, p, target, right, 1n+n)) == True{} : Bool}

law bounded:
  for f: M.Field
  for +p: Nat
  for target: Char
  for right: Bool
  for n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {M.inside(move(f, p, target, right, n)) == True{} : Bool}
