import Base
import ./model.bend as M
import ./axis.bend as A
import ./words.bend as W
import ./find.bend as F
import ./lines.bend as L

law step:
  for state: M.State
  for input: M.Input
  M.State

def axis_key(d: A.Direction) -> Char:
  match d:
    case A.Left{}:
      'h'
    case A.Down{}:
      'j'
    case A.Up{}:
      'k'
    case A.Right{}:
      'l'

def word_key(m: W.Motion, big: Bool) -> Char:
  match m big:
    case W.Forward{} False{}:
      'w'
    case W.Forward{} True{}:
      'W'
    case W.Backward{} False{}:
      'b'
    case W.Backward{} True{}:
      'B'
    case W.End{} False{}:
      'e'
    case W.End{} True{}:
      'E'

def find_mode(right: Bool, n: Nat) -> M.Mode:
  match right:
    case True{}:
      M.FindRight{n}
    case False{}:
      M.FindLeft{n}

def contains(text: String, +c: Char) -> Bool:
  match text:
    case SNil{}:
      False{}
    case SCon{h, rest}:
      Bool.or(Char.is_eq(h, c), contains(rest, c))

def recognized(c: Char) -> Bool:
  contains("hjklwbeWBE0^$fFgG123456789", c)

def digit(c: Char) -> Nat:
  Nat.sub(U32.to_nat(Char.to_u32(c)), 48n)

def append_count(n: Nat, d: Nat) -> Nat:
  Nat.min(9999n, Nat.add(Nat.mul(n, 10n), d))

# Extensionality: hidden storage/caches must not change observable behavior.
law respects_view:
  for +s: M.State
  for +key: M.Input
  {M.view(step(s, key)) == M.view(step(M.pack(M.view(s)), key)) : M.View}

law preserves_field:
  for +s: M.State
  for key: M.Input
  for -ok: {M.valid(M.view(s)) == True{} : Bool}
  {M.board(M.view(step(s, key))) == M.board(M.view(s)) : M.Field}

law preserves_validity:
  for +s: M.State
  for key: M.Input
  for -ok: {M.valid(M.view(s)) == True{} : Bool}
  {M.valid(M.view(step(s, key))) == True{} : Bool}

law other:
  for +s: M.State
  {M.view(step(s, M.Other{})) == M.view(s) : M.View}

law blocked_character:
  for +s: M.State
  for c: Char
  {M.view(step(s, M.Character{c, True{}})) == M.view(s) : M.View}

law blocked_escape:
  for +s: M.State
  {M.view(step(s, M.Escape{True{}})) == M.view(s) : M.View}

law escape:
  for +f: M.Field
  for +p: Nat
  for m: M.Mode
  for -pos: {M.inside(p) == True{} : Bool}
  for -mode: {M.mode_valid(m) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, m}), M.Escape{False{}})) == M.View{f, p, M.Normal{0n}} : M.View}

law nonprintable:
  for +s: M.State
  for +c: Char
  for -no: {M.printable(c) == False{} : Bool}
  {M.view(step(s, M.Character{c, False{}})) == M.view(s) : M.View}

law axis:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +d: A.Direction
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{axis_key(d), False{}})) ==
    M.View{f, A.move(p, d, M.effective(n)), M.Normal{0n}} : M.View}

law words:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +m: W.Motion
  for +big: Bool
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{word_key(m, big), False{}})) ==
    M.View{f, W.move(f, p, m, big, M.effective(n)), M.Normal{0n}} : M.View}

law zero_column:
  for +f: M.Field
  for +p: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{0n}}), M.Character{'0', False{}})) ==
    M.View{f, L.move(f, p, L.ColumnZero{}, 0n), M.Normal{0n}} : M.View}

law first_nonblank:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'^', False{}})) ==
    M.View{f, L.move(f, p, L.FirstNonblank{}, n), M.Normal{0n}} : M.View}

law row_end:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'$', False{}})) ==
    M.View{f, L.move(f, p, L.RowEnd{}, n), M.Normal{0n}} : M.View}

law last_row:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'G', False{}})) ==
    M.View{f, L.move(f, p, L.LastRow{}, n), M.Normal{0n}} : M.View}

law find_right_prefix:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'f', False{}})) ==
    M.View{f, p, M.FindRight{M.effective(n)}} : M.View}

law find_left_prefix:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'F', False{}})) ==
    M.View{f, p, M.FindLeft{M.effective(n)}} : M.View}

law find_target:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +right: Bool
  for +c: Char
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Bool.and(Nat.is_gt(n, 0n), Nat.is_le(n, 9999n)) == True{} : Bool}
  for -char: {M.printable(c) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, find_mode(right, n)}), M.Character{c, False{}})) ==
    M.View{f, F.move(f, p, c, right, n), M.Normal{0n}} : M.View}

law go_prefix:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'g', False{}})) ==
    M.View{f, p, M.Go{n}} : M.View}

law go_complete:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Go{n}}), M.Character{'g', False{}})) ==
    M.View{f, L.move(f, p, L.FirstRow{}, n), M.Normal{0n}} : M.View}

law go_invalid:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +c: Char
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  for -char: {M.printable(c) == True{} : Bool}
  for -not_g: {Char.is_eq(c, 'g') == False{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Go{n}}), M.Character{c, False{}})) ==
    M.View{f, p, M.Normal{0n}} : M.View}

law nonzero_digit:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +c: Char
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  for -char: {Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0'))) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{c, False{}})) ==
    M.View{f, p, M.Normal{append_count(n, digit(c))}} : M.View}

law zero_digit:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Bool.and(Nat.is_gt(n, 0n), Nat.is_le(n, 9999n)) == True{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{'0', False{}})) ==
    M.View{f, p, M.Normal{append_count(n, 0n)}} : M.View}

law unsupported:
  for +f: M.Field
  for +p: Nat
  for +n: Nat
  for +c: Char
  for -pos: {M.inside(p) == True{} : Bool}
  for -count: {Nat.is_le(n, 9999n) == True{} : Bool}
  for -char: {M.printable(c) == True{} : Bool}
  for -unknown: {recognized(c) == False{} : Bool}
  {M.view(step(M.pack(M.View{f, p, M.Normal{n}}), M.Character{c, False{}})) ==
    M.View{f, p, M.Normal{0n}} : M.View}
