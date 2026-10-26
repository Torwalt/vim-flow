import Base

# The representation of these two types belongs to the executor.
law Field:
  Data

law State:
  Data

type Mode is Data:
  Normal{count: Nat}
  FindRight{count: Nat}
  FindLeft{count: Nat}
  Go{count: Nat}

type View is Data:
  View{field: Field, position: Nat, mode: Mode}

# A logical character retains its case. blocked means Ctrl, Alt or Meta.
type Input is Data:
  Character{value: Char, blocked: Bool}
  Escape{blocked: Bool}
  Other{}

law field:
  for text: String
  Field

law at:
  for field: Field
  for position: Nat
  Char

law contents:
  for field: Field
  String

law view:
  for state: State
  View

law pack:
  for snapshot: View
  State

law initial:
  State

def bit(value: Bool) -> Nat:
  match value:
    case False{}:
      0n
    case True{}:
      1n

def printable(+c: Char) -> Bool:
  Bool.or(Char.is_digit(c),
    Bool.and(U32.is_ge(Char.to_u32(c), 32), U32.is_le(Char.to_u32(c), 126)))

def sanitize(c: Char, ok: Bool) -> Char:
  match ok:
    case True{}:
      c
    case False{}:
      ' '

def text_at(text: String, position: Nat) -> Char:
  match text position:
    case SNil{} _:
      ' '
    case SCon{+c, rest} 0n:
      sanitize(c, printable(c))
    case SCon{c, rest} 1n+p:
      text_at(rest, p)

def inside(+p: Nat) -> Bool:
  Nat.is_lt(p, 800n)

def row(p: Nat) -> Nat:
  Nat.div(p, 40n)

def column(p: Nat) -> Nat:
  Nat.mod(p, 40n)

def index(r: Nat, c: Nat) -> Nat:
  Nat.add(Nat.mul(r, 40n), c)

# Zero means no explicit count. Actual movement defaults to one.
def effective(n: Nat) -> Nat:
  Nat.max(1n, n)

def mode_valid(mode: Mode) -> Bool:
  match mode:
    case Normal{n}:
      Nat.is_le(n, 9999n)
    case FindRight{+n}:
      Bool.and(Nat.is_gt(n, 0n), Nat.is_le(n, 9999n))
    case FindLeft{+n}:
      Bool.and(Nat.is_gt(n, 0n), Nat.is_le(n, 9999n))
    case Go{n}:
      Nat.is_le(n, 9999n)

def valid(snapshot: View) -> Bool:
  match snapshot:
    case View{f, p, m}:
      Bool.and(inside(p), mode_valid(m))

def board(snapshot: View) -> Field:
  match snapshot:
    case View{f, p, m}:
      f

def position(snapshot: View) -> Nat:
  match snapshot:
    case View{f, p, m}:
      p

def mode(snapshot: View) -> Mode:
  match snapshot:
    case View{f, p, m}:
      m

# A specification fixture, not a required storage layout. ASCII, with spaces.
def seed_text() -> String:
  "alpha beta  foo_bar ++ 42 \"quote\"       " ++
  "  scout.move(x);  wall## gate  x x      " ++
  "                                        " ++
  "ore_7  unit-2  { north south }  x  END  "

law field_contents:
  for +text: String
  for +p: Nat
  for ok: {inside(p) == True{} : Bool}
  {at(field(text), p) == text_at(text, p) : Char}

law field_printable:
  for f: Field
  for p: Nat
  {printable(at(f, p)) == True{} : Bool}

law field_outside:
  for f: Field
  for +p: Nat
  for outside: {inside(p) == False{} : Bool}
  {at(f, p) == ' ' : Char}

# No empty-domain trick: every valid snapshot has a runtime state.
law pack_view:
  for +snapshot: View
  for ok: {valid(snapshot) == True{} : Bool}
  {view(pack(snapshot)) == snapshot : View}

law initial_view:
  {view(initial) == View{field(seed_text()), 0n, Normal{0n}} : View}

law initial_valid:
  {valid(view(initial)) == True{} : Bool}

# Observations are fixed-width text; private field storage stays abstract.
law contents_length:
  for f: Field
  {String.length(contents(f)) == 800n : Nat}

law contents_at:
  for +f: Field
  for +p: Nat
  for ok: {inside(p) == True{} : Bool}
  {text_at(contents(f), p) == at(f, p) : Char}

def all_printable(text: String) -> Bool:
  match text:
    case SNil{}:
      True{}
    case SCon{c, rest}:
      Bool.and(printable(c), all_printable(rest))

law contents_printable:
  for f: Field
  {all_printable(contents(f)) == True{} : Bool}
