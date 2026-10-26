import Base
import ./model.bend as M

type Motion is Data:
  Forward{}
  Backward{}
  End{}

law move:
  for field: M.Field
  for position: Nat
  for motion: Motion
  for big: Bool
  for count: Nat
  Nat

def class_small(+c: Char) -> Nat:
  M.bit(Bool.or(Bool.or(Char.is_alpha(c), Char.is_digit(c)), Char.is_eq(c, '_')))

# 0 = space; 1 = punctuation; 2 = keyword (ASCII letters/digits/underscore).
def classify(+c: Char, big: Bool) -> Nat:
  match big:
    case True{}:
      Nat.sub(1n, M.bit(Char.is_eq(c, ' ')))
    case False{}:
      Nat.mul(Nat.sub(1n, M.bit(Char.is_eq(c, ' '))), Nat.add(1n, class_small(c)))

def start(+f: String, +big: Bool, +p: Nat) -> Bool:
  Bool.and(M.inside(p), Bool.and(
    Bool.not(Char.is_eq(M.text_at(f, p), ' ')),
    Bool.or(Nat.is_eq(M.column(p), 0n),
      Nat.is_ne(classify(M.text_at(f, Nat.sub(p, 1n)), big), classify(M.text_at(f, p), big)))))

def finish(+f: String, +big: Bool, +p: Nat) -> Bool:
  Bool.and(M.inside(p), Bool.and(
    Bool.not(Char.is_eq(M.text_at(f, p), ' ')),
    Bool.or(Nat.is_eq(M.column(p), 39n),
      Nat.is_ne(classify(M.text_at(f, Nat.add(p, 1n)), big), classify(M.text_at(f, p), big)))))

def candidate(+f: String, +p: Nat, motion: Motion, +big: Bool, +q: Nat) -> Bool:
  match motion:
    case Forward{}:
      Bool.and(Nat.is_gt(q, p), start(f, big, q))
    case Backward{}:
      Bool.and(Nat.is_lt(q, p), start(f, big, q))
    case End{}:
      Bool.and(Nat.is_gt(q, p), finish(f, big, q))

def fallback(motion: Motion) -> Nat:
  match motion:
    case Backward{}:
      0n
    case Forward{}:
      799n
    case End{}:
      799n

def nearer(motion: Motion, selected: Nat, other: Nat) -> Bool:
  match motion:
    case Backward{}:
      Nat.is_ge(selected, other)
    case Forward{}:
      Nat.is_le(selected, other)
    case End{}:
      Nat.is_le(selected, other)

# A relation, not a function computing the destination. If any candidate q
# exists, output must itself be a candidate and at least as near as q.
def Selected(+f: String, +p: Nat, +m: Motion, +big: Bool, +out: Nat) -> Type:
  {Bool.and(M.inside(out), Bool.or(candidate(f, p, m, big, out), Nat.is_eq(out, fallback(m)))) == True{} : Bool}
  & (@+q: Nat ->
    {Bool.or(Bool.not(candidate(f, p, m, big, q)),
      Bool.and(candidate(f, p, m, big, out), nearer(m, out, q))) == True{} : Bool})

law one:
  for +f: M.Field
  for +p: Nat
  for +m: Motion
  for +big: Bool
  for -ok: {M.inside(p) == True{} : Bool}
  Selected(M.contents(f), p, m, big, move(f, p, m, big, 1n))

law zero:
  for f: M.Field
  for +p: Nat
  for m: Motion
  for big: Bool
  {move(f, p, m, big, 0n) == p : Nat}

# Anchored by `one`; this is a decomposition contract, not its own spec.
law counted:
  for +f: M.Field
  for +p: Nat
  for +m: Motion
  for +big: Bool
  for +n: Nat
  for -ok: {M.inside(p) == True{} : Bool}
  {move(f, p, m, big, 2n+n) == move(f, move(f, p, m, big, 1n), m, big, 1n+n) : Nat}

law bounded:
  for f: M.Field
  for +p: Nat
  for m: Motion
  for big: Bool
  for n: Nat
  for -ok: {M.inside(p) == True{} : Bool}
  {M.inside(move(f, p, m, big, n)) == True{} : Bool}
