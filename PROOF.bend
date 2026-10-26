import Base
import ./src/core/scene.bend as Scene
import ./LAWS.bend as Laws
import ./spec/navigation/model.bend as NavigationModel
import ./src/core/navigation_model.bend as NavigationModelImpl

def Laws.one_character_per_cell(value):
  match value:
    case Scene.Floor{}:
      {==}
    case Scene.Wall{}:
      {==}

def NavigationModel.field_contents(text, p, ok):
  %Equal.sym(Bool, NavigationModel.inside(p), True{}, ok) :
    {NavigationModelImpl.at_inside(text, p, _) == NavigationModel.text_at(text, p) : Char}
  {==}

def NavigationModel.field_outside(f, p, outside):
  %Equal.sym(Bool, NavigationModel.inside(p), False{}, outside) :
    {NavigationModelImpl.at_inside(f, p, _) == ' ' : Char}
  {==}

def NavigationModel.pack_view(snapshot, ok):
  {==}

def NavigationModel.initial_view():
  {==}

def NavigationModel.initial_valid():
  {==}

def printable_sanitize(c: Char, ok: Bool, eq: {NavigationModel.printable(c) == ok : Bool}) ->
  {NavigationModel.printable(NavigationModel.sanitize(c, ok)) == True{} : Bool}:
  match ok:
    case True{}:
      eq
    case False{}:
      {==}

law printable_text_at:
  for +text: String
  for +p: Nat
  {NavigationModel.printable(NavigationModel.text_at(text, p)) == True{} : Bool}

def printable_text_at(text, p):
  match text:
    case SNil{}:
      {==}
    case SCon{+c, +rest}:
      match p:
        case 0n:
          printable_sanitize(c, NavigationModel.printable(c), {==})
        case 1n+q:
          printable_text_at(rest, q)

law at_inside_printable:
  for +f: String
  for +p: Nat
  for +ok: Bool
  {NavigationModel.printable(NavigationModelImpl.at_inside(f, p, ok)) == True{} : Bool}

def at_inside_printable(f, p, ok):
  match ok:
    case True{}:
      printable_text_at(f, p)
    case False{}:
      {==}

def field_printable_helper(f: String, +p: Nat) ->
  {NavigationModel.printable(NavigationModelImpl.at_helper(f, p)) == True{} : Bool}:
  at_inside_printable(f, p, NavigationModel.inside(p))

def NavigationModel.field_printable(f, p):
  field_printable_helper(f, p)

law norm_length:
  for +text: String
  for +fuel: Nat
  {String.length(NavigationModelImpl.norm(fuel, text)) == fuel : Nat}

def norm_length(text, fuel):
  match text:
    case SNil{}:
      match fuel:
        case 0n:
          {==}
        case 1n+k:
          %norm_length(SNil{}, k) :
            {Nat.add(1n, String.length(NavigationModelImpl.norm(k, SNil{}))) == Nat.add(1n, _) : Nat}
          {==}
    case SCon{+c, +rest}:
      match fuel:
        case 0n:
          {==}
        case 1n+k:
          %norm_length(rest, k) :
            {Nat.add(1n, String.length(NavigationModelImpl.norm(k, rest))) == Nat.add(1n, _) : Nat}
          {==}

law all_printable_cons:
  for +c: Char
  for +rest: String
  for h: {NavigationModel.printable(c) == True{} : Bool}
  for t: {NavigationModel.all_printable(rest) == True{} : Bool}
  {NavigationModel.all_printable(SCon{c, rest}) == True{} : Bool}

def all_printable_cons(c, rest, h, t):
  %Equal.sym(Bool, NavigationModel.printable(c), True{}, h) :
    {Bool.and(_, NavigationModel.all_printable(rest)) == True{} : Bool}
  %Equal.sym(Bool, NavigationModel.all_printable(rest), True{}, t) :
    {Bool.and(True{}, _) == True{} : Bool}
  {==}

law norm_printable:
  for +text: String
  for +fuel: Nat
  {NavigationModel.all_printable(NavigationModelImpl.norm(fuel, text)) == True{} : Bool}

def norm_printable(text, fuel):
  match text:
    case SNil{}:
      match fuel:
        case 0n:
          {==}
        case 1n+k:
          all_printable_cons(' ', NavigationModelImpl.norm(k, SNil{}), {==}, norm_printable(SNil{}, k))
    case SCon{+c, +rest}:
      match fuel:
        case 0n:
          {==}
        case 1n+k:
          all_printable_cons(NavigationModel.sanitize(c, NavigationModel.printable(c)),
            NavigationModelImpl.norm(k, rest),
            printable_sanitize(c, NavigationModel.printable(c), {==}), norm_printable(rest, k))

law sanitize_idem:
  for +c: Char
  for +ok: Bool
  for eq: {NavigationModel.printable(c) == ok : Bool}
  {NavigationModel.sanitize(NavigationModel.sanitize(c, ok),
    NavigationModel.printable(NavigationModel.sanitize(c, ok))) ==
    NavigationModel.sanitize(c, ok) : Char}

def sanitize_idem(c, ok, eq):
  match ok:
    case True{}:
      %Equal.sym(Bool, NavigationModel.printable(c), True{}, eq) :
        {NavigationModel.sanitize(c, _) == c : Char}
      {==}
    case False{}:
      {==}

def disc(b: Bool) -> Type:
  match b:
    case False{}:
      Empty
    case True{}:
      Unit

def absurd_eq(e: {False{} == True{} : Bool}) -> Empty:
  %Equal.sym(Type, Empty, Unit,
    Equal.cong(Bool, Type, disc, False{}, True{}, e)) : {_ : Type}
  Unit{}

def is_lt_zero(p: Nat) -> {Nat.is_lt(p, 0n) == False{} : Bool}:
  match p:
    case 0n:
      {==}
    case 1n+q:
      {==}

def false_elim(p: Nat, ok: {Nat.is_lt(p, 0n) == True{} : Bool}) -> Empty:
  absurd_eq(Equal.trans(Bool, False{}, Nat.is_lt(p, 0n), True{},
    Equal.sym(Bool, Nat.is_lt(p, 0n), False{}, is_lt_zero(p)), ok))

def empty_elim(-A: Type, e: Empty) -> A:
  match e:

law norm_prefix:
  for +p: Nat
  for +fuel: Nat
  for +text: String
  for ok: {Nat.is_lt(p, fuel) == True{} : Bool}
  {NavigationModel.text_at(NavigationModelImpl.norm(fuel, text), p) ==
    NavigationModel.text_at(text, p) : Char}

def norm_prefix(p, fuel, text, ok):
  match p:
    case 0n:
      match fuel:
        case 0n:
          empty_elim({NavigationModel.text_at(NavigationModelImpl.norm(0n, text), 0n) ==
            NavigationModel.text_at(text, 0n) : Char}, false_elim(0n, ok))
        case 1n+k:
          match text:
            case SNil{}:
              {==}
            case SCon{+c, +rest}:
              sanitize_idem(c, NavigationModel.printable(c), {==})
    case 1n+q:
      match fuel:
        case 0n:
          empty_elim({NavigationModel.text_at(NavigationModelImpl.norm(0n, text), 1n+q) ==
            NavigationModel.text_at(text, 1n+q) : Char}, false_elim(1n+q, ok))
        case 1n+k:
          match text:
            case SNil{}:
              norm_prefix(q, k, SNil{}, ok)
            case SCon{+c, +rest}:
              norm_prefix(q, k, rest, ok)

def NavigationModel.contents_length(f):
  norm_length(f, 800n)

def contents_at_helper(f: String, +p: Nat, +ok: {NavigationModel.inside(p) == True{} : Bool}) ->
  {NavigationModel.text_at(NavigationModelImpl.norm(800n, f), p) ==
    NavigationModelImpl.at_inside(f, p, NavigationModel.inside(p)) : Char}:
  %Equal.sym(Bool, NavigationModel.inside(p), True{}, ok) :
    {NavigationModel.text_at(NavigationModelImpl.norm(800n, f), p) ==
      NavigationModelImpl.at_inside(f, p, _) : Char}
  norm_prefix(p, 800n, f, ok)

def NavigationModel.contents_at(f, p, ok):
  contents_at_helper(f, p, ok)

def NavigationModel.contents_printable(f):
  norm_printable(f, 800n)
