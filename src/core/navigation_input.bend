import Base
import ../../spec/navigation/input.bend as Input
import ../../spec/navigation/model.bend as Model
import ../../spec/navigation/axis.bend as Axis
import ../../spec/navigation/words.bend as Words
import ../../spec/navigation/lines.bend as Lines
import ../../spec/navigation/find.bend as Find
import ./navigation_axis.bend as AxisImpl
import ./navigation_words.bend as WordsImpl
import ./navigation_lines.bend as LinesImpl
import ./navigation_find.bend as FindImpl

def go_input_if(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Lines.move(f, p, Lines.FirstRow{}, n), Model.Normal{0n}}
    case False{}:
      Model.View{f, p, Model.Normal{0n}}

def go_input(+f: Model.Field, +p: Nat, +n: Nat, +c: Char) -> Model.View:
  go_input_if(f, p, n, c, Char.is_eq(c, 'g'))

def normal_big_f(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, p, Model.FindLeft{Model.effective(n)}}
    case False{}:
      Model.View{f, p, Model.Normal{0n}}

def normal_f(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, p, Model.FindRight{Model.effective(n)}}
    case False{}:
      normal_big_f(f, p, n, c, Char.is_eq(c, 'F'))

def normal_g(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, p, Model.Go{n}}
    case False{}:
      normal_f(f, p, n, c, Char.is_eq(c, 'f'))

def normal_big_g(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Lines.move(f, p, Lines.LastRow{}, n), Model.Normal{0n}}
    case False{}:
      normal_g(f, p, n, c, Char.is_eq(c, 'g'))

def normal_dollar(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Lines.move(f, p, Lines.RowEnd{}, n), Model.Normal{0n}}
    case False{}:
      normal_big_g(f, p, n, c, Char.is_eq(c, 'G'))

def normal_caret(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Lines.move(f, p, Lines.FirstNonblank{}, n), Model.Normal{0n}}
    case False{}:
      normal_dollar(f, p, n, c, Char.is_eq(c, '$'))

def normal_big_e(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.End{}, True{}),
        Model.Normal{0n}}
    case False{}:
      normal_caret(f, p, n, c, Char.is_eq(c, '^'))

def normal_e(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.End{}, False{}),
        Model.Normal{0n}}
    case False{}:
      normal_big_e(f, p, n, c, Char.is_eq(c, 'E'))

def normal_big_b(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.Backward{}, True{}),
        Model.Normal{0n}}
    case False{}:
      normal_e(f, p, n, c, Char.is_eq(c, 'e'))

def normal_b(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.Backward{}, False{}),
        Model.Normal{0n}}
    case False{}:
      normal_big_b(f, p, n, c, Char.is_eq(c, 'B'))

def normal_big_w(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.Forward{}, True{}),
        Model.Normal{0n}}
    case False{}:
      normal_b(f, p, n, c, Char.is_eq(c, 'b'))

def normal_w(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, WordsImpl.move_impl(Model.effective(n), f, p, Words.Forward{}, False{}),
        Model.Normal{0n}}
    case False{}:
      normal_big_w(f, p, n, c, Char.is_eq(c, 'W'))

def normal_l(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Axis.move(p, Axis.Right{}, Model.effective(n)), Model.Normal{0n}}
    case False{}:
      normal_w(f, p, n, c, Char.is_eq(c, 'w'))

def normal_k(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Axis.move(p, Axis.Up{}, Model.effective(n)), Model.Normal{0n}}
    case False{}:
      normal_l(f, p, n, c, Char.is_eq(c, 'l'))

def normal_j(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Axis.move(p, Axis.Down{}, Model.effective(n)), Model.Normal{0n}}
    case False{}:
      normal_k(f, p, n, c, Char.is_eq(c, 'k'))

def normal_h(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  hit: Bool) -> Model.View:
  match hit:
    case True{}:
      Model.View{f, Axis.move(p, Axis.Left{}, Model.effective(n)), Model.Normal{0n}}
    case False{}:
      normal_j(f, p, n, c, Char.is_eq(c, 'j'))

def normal_zero(+f: Model.Field, +p: Nat, +n: Nat) -> Model.View:
  match n:
    case 0n:
      Model.View{f, Lines.move(f, p, Lines.ColumnZero{}, 0n), Model.Normal{0n}}
    case 1n+k:
      Model.View{f, p, Model.Normal{Input.append_count(1n+k, 0n)}}

def normal_zero_digit(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  zero: Bool) -> Model.View:
  match zero:
    case True{}:
      normal_zero(f, p, n)
    case False{}:
      normal_h(f, p, n, c, Char.is_eq(c, 'h'))

def normal_nonzero_digit(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  nonzero: Bool) -> Model.View:
  match nonzero:
    case True{}:
      Model.View{f, p, Model.Normal{Input.append_count(n, Input.digit(c))}}
    case False{}:
      normal_zero_digit(f, p, n, c, Char.is_eq(c, '0'))

def normal_supported(+f: Model.Field, +p: Nat, +n: Nat, +c: Char) -> Model.View:
  normal_nonzero_digit(f, p, n, c,
    Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0'))))

def normal_known(+f: Model.Field, +p: Nat, +n: Nat, +c: Char,
  known: Bool) -> Model.View:
  match known:
    case True{}:
      normal_supported(f, p, n, c)
    case False{}:
      Model.View{f, p, Model.Normal{0n}}

def normal_input(+f: Model.Field, +p: Nat, +n: Nat, +c: Char) -> Model.View:
  normal_known(f, p, n, c, Input.recognized(c))

def character_printable(state: Model.State, +c: Char) -> Model.View:
  match state:
    case Model.View{+f, +p, m}:
      match m:
        case Model.Normal{n}:
          normal_input(f, p, n, c)
        case Model.FindRight{n}:
          Model.View{f, Find.move(f, p, c, True{}, n), Model.Normal{0n}}
        case Model.FindLeft{n}:
          Model.View{f, Find.move(f, p, c, False{}, n), Model.Normal{0n}}
        case Model.Go{n}:
          go_input(f, p, n, c)

def character_active_if(state: Model.State, +c: Char, printable: Bool) -> Model.View:
  match printable:
    case True{}:
      character_printable(state, c)
    case False{}:
      state

def character_active(state: Model.State, +c: Char) -> Model.View:
  character_active_if(state, c, Model.printable(c))

def character_input(state: Model.State, +c: Char, blocked: Bool) -> Model.View:
  match blocked:
    case True{}:
      state
    case False{}:
      character_active(state, c)

def clear_state(state: Model.State) -> Model.View:
  match state:
    case Model.View{f, p, m}:
      Model.View{f, p, Model.Normal{0n}}

def escape_input(state: Model.State, blocked: Bool) -> Model.View:
  match blocked:
    case True{}:
      state
    case False{}:
      clear_state(state)

def Input.step(state, input):
  match input:
    case Model.Other{}:
      state
    case Model.Escape{blocked}:
      escape_input(state, blocked)
    case Model.Character{value, blocked}:
      character_input(state, value, blocked)
