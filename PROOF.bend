import Base
import ./src/core/scene.bend as Scene
import ./LAWS.bend as Laws
import ./spec/navigation/model.bend as NavigationModel
import ./src/core/navigation_model.bend as NavigationModelImpl
import ./spec/navigation/axis.bend as NavigationAxis
import ./src/core/navigation_axis.bend as NavigationAxisImpl
import ./spec/navigation/words.bend as NavigationWords
import ./src/core/navigation_words.bend as NavigationWordsImpl
import ./spec/navigation/lines.bend as NavigationLines
import ./spec/navigation/find.bend as NavigationFind
import ./src/core/navigation_lines.bend as NavigationLinesImpl
import ./src/core/navigation_find.bend as NavigationFindImpl
import ./spec/navigation/input.bend as NavigationInput
import ./src/core/navigation_input.bend as NavigationInputImpl

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

law add40_lt:
  for +x: Nat
  for +y: Nat
  for h: {Nat.is_lt(Nat.add(40n, x), Nat.add(40n, y)) == True{} : Bool}
  {Nat.is_lt(x, y) == True{} : Bool}

def add40_lt(x, y, h):
  h

law div_bound:
  for +d: Nat
  for +r: Nat
  for +b: Nat
  for h: {Nat.is_lt(Nat.add(Nat.mul(d, 40n), r), Nat.mul(b, 40n)) == True{} : Bool}
  {Nat.is_lt(d, b) == True{} : Bool}

def div_bound(d, r, b, h):
  match d:
    case 0n:
      match b:
        case 0n:
          empty_elim({Nat.is_lt(0n, 0n) == True{} : Bool}, false_elim(r, h))
        case 1n+q:
          {==}
    case 1n+p:
      match b:
        case 0n:
          empty_elim({Nat.is_lt(1n+p, 0n) == True{} : Bool},
            false_elim(Nat.add(Nat.mul(1n+p, 40n), r), h))
        case 1n+q:
          div_bound(p, r, q,
            add40_lt(Nat.add(Nat.mul(p, 40n), r), Nat.mul(q, 40n), h))

law add_zero_r:
  for +a: Nat
  {Nat.add(a, 0n) == a : Nat}

def add_zero_r(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      %add_zero_r(p) : {1n+Nat.add(p, 0n) == 1n+_ : Nat}
      {==}

law add_succ_r:
  for +a: Nat
  for +b: Nat
  {Nat.add(a, 1n+b) == 1n+Nat.add(a, b) : Nat}

def add_succ_r(a, b):
  match a:
    case 0n:
      {==}
    case 1n+p:
      %add_succ_r(p, b) : {1n+Nat.add(p, 1n+b) == 1n+_ : Nat}
      {==}

law add_comm:
  for +a: Nat
  for +b: Nat
  {Nat.add(a, b) == Nat.add(b, a) : Nat}

def add_comm(a, b):
  match a:
    case 0n:
      %Equal.sym(Nat, Nat.add(b, 0n), b, add_zero_r(b)) : {b == _ : Nat}
      {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(b, 1n+p), 1n+Nat.add(b, p), add_succ_r(b, p)) :
        {1n+Nat.add(p, b) == _ : Nat}
      %Equal.sym(Nat, Nat.add(p, b), Nat.add(b, p), add_comm(p, b)) :
        {1n+_ == 1n+Nat.add(b, p) : Nat}
      {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.add(b, p), 1n+Nat.add(b, p), add_succ_r(b, p)) :
        {1n+Nat.add(p, b) == _ : Nat}
      %Equal.sym(Nat, Nat.add(b, p), Nat.add(p, b), add_comm(p, b)) :
        {1n+_ == 1n+Nat.add(b, p) : Nat}
      {==}
    case 1n+p:
      %add_succ_r(b, p) :
        {1n+Nat.add(p, b) == 1n+_ : Nat}
      %add_comm(p, b) : {1n+Nat.add(p, b) == 1n+_ : Nat}
      {==}

law inv_step_rem:
  for +n: Nat
  for +d: Nat
  for +r: Nat
  for +x: Nat
  for eq: {Nat.add(1n+n, Nat.add(Nat.mul(d, 40n), r)) == x : Nat}
  {Nat.add(n, Nat.add(Nat.mul(d, 40n), 1n+r)) == x : Nat}

def inv_step_rem(n, d, r, x, eq):
  %Equal.sym(Nat, Nat.add(Nat.mul(d, 40n), 1n+r),
    1n+Nat.add(Nat.mul(d, 40n), r), add_succ_r(Nat.mul(d, 40n), r)) :
    {Nat.add(n, _) == x : Nat}
  %Equal.sym(Nat, Nat.add(n, 1n+Nat.add(Nat.mul(d, 40n), r)),
    1n+Nat.add(n, Nat.add(Nat.mul(d, 40n), r)),
    add_succ_r(n, Nat.add(Nat.mul(d, 40n), r))) :
    {_ == x : Nat}
  eq

law inv_step_reset:
  for +n: Nat
  for +d: Nat
  for +r: Nat
  for +x: Nat
  for eq: {Nat.add(1n+n, Nat.add(Nat.mul(d, 40n), r)) == x : Nat}
  for r39: {r == 39n : Nat}
  {Nat.add(n, Nat.add(Nat.mul(1n+d, 40n), 0n)) == x : Nat}

def inv_step_reset(n, d, r, x, eq, r39):
  %Equal.sym(Nat, Nat.add(Nat.mul(1n+d, 40n), 0n), Nat.mul(1n+d, 40n),
    add_zero_r(Nat.mul(1n+d, 40n))) :
    {Nat.add(n, _) == x : Nat}
  %Equal.sym(Nat, Nat.add(n, 1n+Nat.add(39n, Nat.mul(d, 40n))),
    1n+Nat.add(n, Nat.add(39n, Nat.mul(d, 40n))),
    add_succ_r(n, Nat.add(39n, Nat.mul(d, 40n)))) :
    {_ == x : Nat}
  %Equal.sym(Nat, Nat.add(39n, Nat.mul(d, 40n)), Nat.add(Nat.mul(d, 40n), 39n),
    add_comm(39n, Nat.mul(d, 40n))) :
    {1n+Nat.add(n, _) == x : Nat}
  %r39 :
    {1n+Nat.add(n, Nat.add(Nat.mul(d, 40n), _)) == x : Nat}
  eq


law rm_step_rem:
  for +r: Nat
  for +m: Nat
  for rm: {Nat.add(r, 1n+m) == 39n : Nat}
  {Nat.add(1n+r, m) == 39n : Nat}

def rm_step_rem(r, m, rm):
  %add_succ_r(r, m) : {_ == 39n : Nat}
  rm

def lt_of_eq(x: Nat, y: Nat, eq: {x == y : Nat},
  h: {Nat.is_lt(y, 800n) == True{} : Bool}) ->
  {Nat.is_lt(x, 800n) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(x, 800n), Nat.is_lt(y, 800n), True{},
    Equal.cong(Nat, Bool, (z => Nat.is_lt(z, 800n)), x, y, eq), h)

law div_bound_800:
  for +d: Nat
  for +r: Nat
  for h: {Nat.is_lt(Nat.add(Nat.mul(d, 40n), r), 800n) == True{} : Bool}
  {Nat.is_lt(d, 20n) == True{} : Bool}

def div_bound_800(d, r, h):
  div_bound(d, r, 20n, h)

def r_of_rm_zero(r: Nat, rm: {Nat.add(r, 0n) == 39n : Nat}) ->
  {r == 39n : Nat}:
  Equal.trans(Nat, r, Nat.add(r, 0n), 39n,
    Equal.sym(Nat, Nat.add(r, 0n), r, add_zero_r(r)), rm)

law divmod_go_quot:
  for +a: Nat
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for inv: {Nat.add(n, Nat.add(Nat.mul(d, 40n), r)) == a : Nat}
  for +rm: {Nat.add(r, m) == 39n : Nat}
  for h: {Nat.is_lt(a, 800n) == True{} : Bool}
  {Nat.is_lt(Pair.fst(Nat, Nat, Nat.divmod.go(n, m, d, r)), 20n) == True{} : Bool}

def divmod_go_quot(a, n, m, d, r, inv, rm, h):
  match n:
    case 0n:
      div_bound_800(d, r, lt_of_eq(Nat.add(Nat.mul(d, 40n), r), a, inv, h))
    case 1n+np:
      match m:
        case 0n:
          divmod_go_quot(a, np, r, 1n+d, 0n,
            inv_step_reset(np, d, r, a, inv, r_of_rm_zero(r, rm)),
            r_of_rm_zero(r, rm), h)
        case 1n+mp:
          divmod_go_quot(a, np, mp, d, 1n+r,
            inv_step_rem(np, d, r, a, inv), rm_step_rem(r, mp, rm), h)

law lt_add_left:
  for +c: Nat
  for +k: Nat
  for +x: Nat
  for h: {Nat.is_lt(c, k) == True{} : Bool}
  {Nat.is_lt(c, Nat.add(k, x)) == True{} : Bool}

def lt_add_left(c, k, x, h):
  match c:
    case 0n:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(0n, Nat.add(0n, x)) == True{} : Bool},
            false_elim(0n, h))
        case 1n+q:
          {==}
    case 1n+p:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(1n+p, Nat.add(0n, x)) == True{} : Bool},
            false_elim(1n+p, h))
        case 1n+q:
          lt_add_left(p, q, x, h)

law lt_succ:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_lt(a, b) == True{} : Bool}
  {Nat.is_lt(a, 1n+b) == True{} : Bool}

def lt_succ(a, b, h):
  match a:
    case 0n:
      {==}
    case 1n+p:
      match b:
        case 0n:
          empty_elim({Nat.is_lt(1n+p, 1n+0n) == True{} : Bool},
            false_elim(1n+p, h))
        case 1n+q:
          lt_succ(p, q, h)

law sub_lt:
  for +c: Nat
  for +n: Nat
  for +k: Nat
  for h: {Nat.is_lt(c, k) == True{} : Bool}
  {Nat.is_lt(Nat.sub(c, n), k) == True{} : Bool}

def sub_lt(c, n, k, h):
  match c:
    case 0n:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(Nat.sub(0n, n), 0n) == True{} : Bool},
            false_elim(0n, h))
        case 1n+t:
          {==}
    case 1n+p:
      match n:
        case 0n:
          h
        case 1n+q:
          match k:
            case 0n:
              empty_elim({Nat.is_lt(Nat.sub(1n+p, 1n+q), 0n) == True{} : Bool},
                false_elim(1n+p, h))
            case 1n+t:
              lt_succ(Nat.sub(p, q), t, sub_lt(p, q, t, h))

law min_lt:
  for +a: Nat
  for +b: Nat
  for +k: Nat
  for h: {Nat.is_lt(a, k) == True{} : Bool}
  {Nat.is_lt(Nat.min(a, b), k) == True{} : Bool}

def min_lt(a, b, k, h):
  match a:
    case 0n:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(Nat.min(0n, b), 0n) == True{} : Bool},
            false_elim(0n, h))
        case 1n+t:
          {==}
    case 1n+p:
      match b:
        case 0n:
          match k:
            case 0n:
              empty_elim({Nat.is_lt(Nat.min(1n+p, 0n), 0n) == True{} : Bool},
                false_elim(1n+p, h))
            case 1n+t:
              {==}
        case 1n+q:
          match k:
            case 0n:
              empty_elim({Nat.is_lt(Nat.min(1n+p, 1n+q), 0n) == True{} : Bool},
                false_elim(1n+p, h))
            case 1n+t:
              min_lt(p, q, t, h)

law add_mul_lt:
  for +r: Nat
  for +c: Nat
  for +k: Nat
  for rc: {Nat.is_lt(r, k) == True{} : Bool}
  for cc: {Nat.is_lt(c, 40n) == True{} : Bool}
  {Nat.is_lt(Nat.add(Nat.mul(r, 40n), c), Nat.mul(k, 40n)) == True{} : Bool}

def add_mul_lt(r, c, k, rc, cc):
  match r:
    case 0n:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(Nat.add(Nat.mul(0n, 40n), c), Nat.mul(0n, 40n)) == True{} : Bool},
            false_elim(0n, rc))
        case 1n+q:
          lt_add_left(c, 40n, Nat.mul(q, 40n), cc)
    case 1n+p:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(Nat.add(Nat.mul(1n+p, 40n), c), Nat.mul(0n, 40n)) == True{} : Bool},
            false_elim(1n+p, rc))
        case 1n+q:
          add_mul_lt(p, c, q, rc, cc)



def zero_disc(n: Nat) -> Type:
  match n:
    case 0n:
      Unit
    case 1n+p:
      Empty

def empty_of_unit_eq(e: {Empty == Unit : Type}) -> Empty:
  %Equal.sym(Type, Empty, Unit, e) : {_ : Type}
  Unit{}

def succ_ne_zero(n: Nat, e: {1n+n == 0n : Nat}) -> Empty:
  empty_of_unit_eq(Equal.cong(Nat, Type, zero_disc, 1n+n, 0n, e))

def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

def succ_inj(a: Nat, b: Nat, e: {1n+a == 1n+b : Nat}) -> {a == b : Nat}:
  Equal.cong(Nat, Nat, pred, 1n+a, 1n+b, e)

law zero_lt_add_one:
  for +m: Nat
  {Nat.is_lt(0n, Nat.add(m, 1n)) == True{} : Bool}

def zero_lt_add_one(m):
  match m:
    case 0n:
      {==}
    case 1n+p:
      {==}

law add_eq_lt_succ:
  for +r: Nat
  for +m: Nat
  for +k: Nat
  for eq: {Nat.add(r, m) == k : Nat}
  {Nat.is_lt(r, Nat.add(k, 1n)) == True{} : Bool}

def add_eq_lt_succ(r, m, k, eq):
  match r:
    case 0n:
      %eq : {Nat.is_lt(0n, Nat.add(_, 1n)) == True{} : Bool}
      zero_lt_add_one(m)
    case 1n+p:
      match k:
        case 0n:
          empty_elim({Nat.is_lt(1n+p, Nat.add(0n, 1n)) == True{} : Bool},
            succ_ne_zero(Nat.add(p, m), eq))
        case 1n+q:
          add_eq_lt_succ(p, m, q, succ_inj(Nat.add(p, m), q, eq))

law divmod_go_rem:
  for +a: Nat
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for inv: {Nat.add(n, Nat.add(Nat.mul(d, 40n), r)) == a : Nat}
  for +rm: {Nat.add(r, m) == 39n : Nat}
  {Nat.is_lt(Pair.snd(Nat, Nat, Nat.divmod.go(n, m, d, r)), 40n) == True{} : Bool}

def divmod_go_rem(a, n, m, d, r, inv, rm):
  match n:
    case 0n:
      add_eq_lt_succ(r, m, 39n, rm)
    case 1n+np:
      match m:
        case 0n:
          divmod_go_rem(a, np, r, 1n+d, 0n,
            inv_step_reset(np, d, r, a, inv, r_of_rm_zero(r, rm)),
            r_of_rm_zero(r, rm))
        case 1n+mp:
          divmod_go_rem(a, np, mp, d, 1n+r,
            inv_step_rem(np, d, r, a, inv), rm_step_rem(r, mp, rm))

law row_lt_20:
  for +p: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {Nat.is_lt(NavigationModel.row(p), 20n) == True{} : Bool}

def row_lt_20(p, ok):
  divmod_go_quot(p, p, 39n, 0n, 0n, add_zero_r(p), {==}, ok)

law col_lt_40:
  for +p: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {Nat.is_lt(NavigationModel.column(p), 40n) == True{} : Bool}

def col_lt_40(p, ok):
  divmod_go_rem(p, p, 39n, 0n, 0n, add_zero_r(p), {==})

law index_inside:
  for +r: Nat
  for +c: Nat
  for hr: {Nat.is_lt(r, 20n) == True{} : Bool}
  for hc: {Nat.is_lt(c, 40n) == True{} : Bool}
  {NavigationModel.inside(NavigationModel.index(r, c)) == True{} : Bool}

def index_inside(r, c, hr, hc):
  add_mul_lt(r, c, 20n, hr, hc)

law left_inside:
  for +p: Nat
  for +n: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {NavigationModel.inside(NavigationModel.index(NavigationModel.row(p),
    Nat.sub(NavigationModel.column(p), n))) == True{} : Bool}

def left_inside(p, n, ok):
  index_inside(NavigationModel.row(p), Nat.sub(NavigationModel.column(p), n),
    row_lt_20(p, ok), sub_lt(NavigationModel.column(p), n, 40n, col_lt_40(p, ok)))

law right_inside:
  for +p: Nat
  for +n: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {NavigationModel.inside(NavigationModel.index(NavigationModel.row(p),
    Nat.min(39n, Nat.add(NavigationModel.column(p), n)))) == True{} : Bool}

def right_inside(p, n, ok):
  index_inside(NavigationModel.row(p),
    Nat.min(39n, Nat.add(NavigationModel.column(p), n)),
    row_lt_20(p, ok),
    min_lt(39n, Nat.add(NavigationModel.column(p), n), 40n, {==}))

law up_inside:
  for +p: Nat
  for +n: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {NavigationModel.inside(NavigationModel.index(Nat.sub(NavigationModel.row(p), n),
    NavigationModel.column(p))) == True{} : Bool}

def up_inside(p, n, ok):
  index_inside(Nat.sub(NavigationModel.row(p), n), NavigationModel.column(p),
    sub_lt(NavigationModel.row(p), n, 20n, row_lt_20(p, ok)), col_lt_40(p, ok))

law down_inside:
  for +p: Nat
  for +n: Nat
  for +ok: {NavigationModel.inside(p) == True{} : Bool}
  {NavigationModel.inside(NavigationModel.index(Nat.min(19n,
    Nat.add(NavigationModel.row(p), n)), NavigationModel.column(p))) == True{} : Bool}

def down_inside(p, n, ok):
  index_inside(Nat.min(19n, Nat.add(NavigationModel.row(p), n)),
    NavigationModel.column(p),
    min_lt(19n, Nat.add(NavigationModel.row(p), n), 20n, {==}),
    col_lt_40(p, ok))

def NavigationAxis.left(p, n, ok):
  {==}

def NavigationAxis.right(p, n, ok):
  {==}

def NavigationAxis.up(p, n, ok):
  {==}

def NavigationAxis.down(p, n, ok):
  {==}

def NavigationAxis.bounded(p, direction, n, ok):
  match direction:
    case NavigationAxis.Left{}:
      left_inside(p, n, ok)
    case NavigationAxis.Down{}:
      down_inside(p, n, ok)
    case NavigationAxis.Up{}:
      up_inside(p, n, ok)
    case NavigationAxis.Right{}:
      right_inside(p, n, ok)

law and_left:
  for a: Bool
  for b: Bool
  for h: {Bool.and(a,b) == True{} : Bool}
  {a == True{} : Bool}
def and_left(a, b, h):
  match a:
    case False{}:
      empty_elim({False{} == True{} : Bool}, absurd_eq(h))
    case True{}:
      {==}

law and_right:
  for a: Bool
  for b: Bool
  for h: {Bool.and(a,b) == True{} : Bool}
  {b == True{} : Bool}
def and_right(a, b, h):
  match a:
    case False{}:
      empty_elim({b == True{} : Bool}, absurd_eq(h))
    case True{}:
      h

law and_intro:
  for a: Bool
  for b: Bool
  for ha: {a == True{} : Bool}
  for hb: {b == True{} : Bool}
  {Bool.and(a,b) == True{} : Bool}
def and_intro(a, b, ha, hb):
  match a:
    case False{}:
      empty_elim({Bool.and(False{},b) == True{} : Bool}, absurd_eq(ha))
    case True{}:
      hb

law or_true_r:
  for b: Bool
  {Bool.or(b, True{}) == True{} : Bool}
def or_true_r(b):
  match b:
    case False{}:
      {==}
    case True{}:
      {==}

law or_not_min:
  for c: Bool
  for r: Bool
  for hr: {c == True{} : Bool} -> {r == True{} : Bool}
  {Bool.or(Bool.not(c), r) == True{} : Bool}
def or_not_min(c, r, hr):
  match c:
    case False{}:
      {==}
    case True{}:
      hr({==})

law zero_le:
  for +b: Nat
  {Nat.is_le(0n,b) == True{} : Bool}
def zero_le(b):
  match b:
    case 0n:
      {==}
    case 1n+q:
      {==}

law is_eq_refl:
  for +a: Nat
  {Nat.is_eq(a,a) == True{} : Bool}
def is_eq_refl(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      is_eq_refl(p)

law is_eq_eq:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_eq(a,b) == True{} : Bool}
  {a == b : Nat}
def is_eq_eq(a, b, h):
  match a b:
    case 0n 0n:
      {==}
    case 0n 1n+q:
      empty_elim({0n == 1n+q : Nat}, absurd_eq(h))
    case 1n+p 0n:
      empty_elim({1n+p == 0n : Nat}, absurd_eq(h))
    case 1n+p 1n+q:
      Equal.cong(Nat, Nat, (z => 1n+z), p, q, is_eq_eq(p, q, h))

law eq_is_eq:
  for +a: Nat
  for +b: Nat
  for e: {a == b : Nat}
  {Nat.is_eq(a,b) == True{} : Bool}
def eq_is_eq(a, b, e):
  %e : {Nat.is_eq(a, _) == True{} : Bool}
  is_eq_refl(a)

law not_true_of_contra:
  for b: Bool
  for h: {b == True{} : Bool} -> Empty
  {Bool.not(b) == True{} : Bool}
def not_true_of_contra(b, h):
  match b:
    case False{}:
      {==}
    case True{}:
      empty_elim({Bool.not(True{}) == True{} : Bool}, h({==}))

law is_ne_swap:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_ne(a,b) == True{} : Bool}
  {Nat.is_ne(b,a) == True{} : Bool}
def is_ne_swap(a, b, h):
  match a b:
    case 0n 0n:
      empty_elim({Nat.is_ne(0n,0n) == True{} : Bool}, absurd_eq(h))
    case 0n 1n+q:
      {==}
    case 1n+p 0n:
      {==}
    case 1n+p 1n+q:
      is_ne_swap(p, q, h)

law le_of_lt:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_lt(a,b) == True{} : Bool}
  {Nat.is_le(a,b) == True{} : Bool}
def le_of_lt(a, b, h):
  match a b:
    case 0n 0n:
      empty_elim({Nat.is_le(0n,0n) == True{} : Bool}, absurd_eq(h))
    case 0n 1n+q:
      {==}
    case 1n+p 0n:
      empty_elim({Nat.is_le(1n+p,0n) == True{} : Bool}, absurd_eq(h))
    case 1n+p 1n+q:
      le_of_lt(p, q, h)

law succ_le_of_lt:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_lt(a,b) == True{} : Bool}
  {Nat.is_le(Nat.add(a,1n),b) == True{} : Bool}
def succ_le_of_lt(a, b, h):
  match a b:
    case 0n 0n:
      empty_elim({Nat.is_le(Nat.add(0n,1n),0n) == True{} : Bool}, absurd_eq(h))
    case 0n 1n+q:
      zero_le(q)
    case 1n+p 0n:
      empty_elim({Nat.is_le(Nat.add(1n+p,1n),0n) == True{} : Bool}, absurd_eq(h))
    case 1n+p 1n+q:
      succ_le_of_lt(p, q, h)

law cmp_lt_of_le_ne:
  for c: Cmp
  for le: {Cmp.is_le(c) == True{} : Bool}
  for ne: {Bool.not(Cmp.is_eq(c)) == True{} : Bool}
  {Cmp.is_lt(c) == True{} : Bool}
def cmp_lt_of_le_ne(c, le, ne):
  match c:
    case LT{}:
      {==}
    case EQ{}:
      empty_elim({Cmp.is_lt(EQ{}) == True{} : Bool}, absurd_eq(ne))
    case GT{}:
      empty_elim({Cmp.is_lt(GT{}) == True{} : Bool}, absurd_eq(le))

law lt_of_le_ne:
  for +a: Nat
  for +b: Nat
  for le: {Nat.is_le(a,b) == True{} : Bool}
  for ne: {Nat.is_ne(a,b) == True{} : Bool}
  {Nat.is_lt(a,b) == True{} : Bool}
def lt_of_le_ne(a, b, le, ne):
  cmp_lt_of_le_ne(Nat.cmp(a,b), le, ne)

law lt_zero:
  for +a: Nat
  {Nat.is_lt(a,0n) == False{} : Bool}
def lt_zero(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      {==}

law le_lt_absurd:
  for +a: Nat
  for +b: Nat
  for le: {Nat.is_le(a,b) == True{} : Bool}
  for lt: {Nat.is_lt(b,a) == True{} : Bool}
  {False{} == True{} : Bool}
def le_lt_absurd(a, b, le, lt):
  match a b:
    case 0n 0n:
      lt
    case 0n 1n+q:
      lt
    case 1n+p 0n:
      le
    case 1n+p 1n+q:
      le_lt_absurd(p, q, le, lt)

law le_pred_of_lt:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_lt(a, 1n+b) == True{} : Bool}
  {Nat.is_le(a,b) == True{} : Bool}
def le_pred_of_lt(a, b, h):
  match a b:
    case 0n _:
      zero_le(b)
    case 1n+p 0n:
      empty_elim({Nat.is_le(1n+p,0n) == True{} : Bool},
        absurd_eq(Equal.trans(Bool, False{}, Nat.is_lt(p,0n), True{},
          Equal.sym(Bool, Nat.is_lt(p,0n), False{}, lt_zero(p)), h)))
    case 1n+p 1n+q:
      le_pred_of_lt(p, q, h)

law le_ge_swap:
  for +a: Nat
  for +b: Nat
  {Nat.is_ge(a,b) == Nat.is_le(b,a) : Bool}
def le_ge_swap(a, b):
  match a b:
    case 0n 0n:
      {==}
    case 0n 1n+q:
      {==}
    case 1n+p 0n:
      {==}
    case 1n+p 1n+q:
      le_ge_swap(p, q)

law ge_of_le:
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_le(a,b) == True{} : Bool}
  {Nat.is_ge(b,a) == True{} : Bool}
def ge_of_le(a, b, h):
  Equal.trans(Bool, Nat.is_ge(b,a), Nat.is_le(a,b), True{}, le_ge_swap(b,a), h)

law lt_add_zero_r:
  for +q: Nat
  for +q0: Nat
  for h: {Nat.is_lt(q0, Nat.add(q,0n)) == True{} : Bool}
  {Nat.is_lt(q0, q) == True{} : Bool}
def lt_add_zero_r(q, q0, h):
  Equal.trans(Bool, Nat.is_lt(q0,q), Nat.is_lt(q0,Nat.add(q,0n)), True{},
    Equal.sym(Bool, Nat.is_lt(q0,Nat.add(q,0n)), Nat.is_lt(q0,q),
      Equal.cong(Nat, Bool, (z => Nat.is_lt(q0,z)), Nat.add(q,0n), q, add_zero_r(q))),
    h)

law add_one_assoc:
  for +q: Nat
  for +k: Nat
  {Nat.add(q, Nat.add(1n,k)) == Nat.add(Nat.add(q,1n),k) : Nat}
def add_one_assoc(q, k):
  match q:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, (z => 1n+z),
        Nat.add(p, Nat.add(1n,k)), Nat.add(Nat.add(p,1n),k),
        add_one_assoc(p, k))

law lt_add_one_assoc:
  for +q: Nat
  for +k: Nat
  for +q0: Nat
  for h: {Nat.is_lt(q0, Nat.add(q, Nat.add(1n,k))) == True{} : Bool}
  {Nat.is_lt(q0, Nat.add(Nat.add(q,1n),k)) == True{} : Bool}
def lt_add_one_assoc(q, k, q0, h):
  Equal.trans(Bool,
    Nat.is_lt(q0, Nat.add(Nat.add(q,1n),k)),
    Nat.is_lt(q0, Nat.add(q, Nat.add(1n,k))), True{},
    Equal.sym(Bool, Nat.is_lt(q0, Nat.add(q, Nat.add(1n,k))),
      Nat.is_lt(q0, Nat.add(Nat.add(q,1n),k)),
      Equal.cong(Nat, Bool, (z => Nat.is_lt(q0, z)),
        Nat.add(q, Nat.add(1n,k)), Nat.add(Nat.add(q,1n),k),
        add_one_assoc(q, k))),
    h)

def candidate_congr(+f: String, +p: Nat, +motion: NavigationWords.Motion, +big: Bool,
  +a: Nat, +b: Nat, e: {a == b : Nat}) ->
  {NavigationWords.candidate(f,p,motion,big,a) ==
    NavigationWords.candidate(f,p,motion,big,b) : Bool}:
  Equal.cong(Nat, Bool, (z => NavigationWords.candidate(f,p,motion,big,z)), a, b, e)

def candidate_inside(+f: String, +p: Nat, +motion: NavigationWords.Motion, +big: Bool,
  +q: Nat, h: {NavigationWords.candidate(f,p,motion,big,q) == True{} : Bool}) ->
  {NavigationModel.inside(q) == True{} : Bool}:
  match motion:
    case NavigationWords.Forward{}:
      and_left(NavigationModel.inside(q), Bool.and(
        Bool.not(Char.is_eq(NavigationModel.text_at(f,q), ' ')),
        Bool.or(Nat.is_eq(NavigationModel.column(q),0n),
          Nat.is_ne(NavigationWords.classify(NavigationModel.text_at(f,Nat.sub(q,1n)),big),
            NavigationWords.classify(NavigationModel.text_at(f,q),big)))),
        and_right(Nat.is_gt(q,p), NavigationWords.start(f,big,q), h))
    case NavigationWords.Backward{}:
      and_left(NavigationModel.inside(q), Bool.and(
        Bool.not(Char.is_eq(NavigationModel.text_at(f,q), ' ')),
        Bool.or(Nat.is_eq(NavigationModel.column(q),0n),
          Nat.is_ne(NavigationWords.classify(NavigationModel.text_at(f,Nat.sub(q,1n)),big),
            NavigationWords.classify(NavigationModel.text_at(f,q),big)))),
        and_right(Nat.is_lt(q,p), NavigationWords.start(f,big,q), h))
    case NavigationWords.End{}:
      and_left(NavigationModel.inside(q), Bool.and(
        Bool.not(Char.is_eq(NavigationModel.text_at(f,q), ' ')),
        Bool.or(Nat.is_eq(NavigationModel.column(q),39n),
          Nat.is_ne(NavigationWords.classify(NavigationModel.text_at(f,Nat.add(q,1n)),big),
            NavigationWords.classify(NavigationModel.text_at(f,q),big)))),
        and_right(Nat.is_gt(q,p), NavigationWords.finish(f,big,q), h))

def candidates_conflict(+f: String, +p: Nat, +motion: NavigationWords.Motion, +big: Bool,
  +a: Nat, +b: Nat,
  hf: {NavigationWords.candidate(f,p,motion,big,a) == False{} : Bool},
  ht: {NavigationWords.candidate(f,p,motion,big,b) == True{} : Bool},
  h: {Nat.is_eq(a,b) == True{} : Bool}) -> Empty:
  absurd_eq(Equal.trans(Bool, False{}, NavigationWords.candidate(f,p,motion,big,a), True{},
    Equal.sym(Bool, NavigationWords.candidate(f,p,motion,big,a), False{}, hf),
    Equal.trans(Bool, NavigationWords.candidate(f,p,motion,big,a),
      NavigationWords.candidate(f,p,motion,big,b), True{},
      candidate_congr(f,p,motion,big,a,b, is_eq_eq(a,b,h)), ht)))

def ne_of_candidates_conflict(+f: String, +p: Nat, +motion: NavigationWords.Motion, +big: Bool,
  +a: Nat, +b: Nat,
  hf: {NavigationWords.candidate(f,p,motion,big,a) == False{} : Bool},
  ht: {NavigationWords.candidate(f,p,motion,big,b) == True{} : Bool}) ->
  {Nat.is_ne(a,b) == True{} : Bool}:
  not_true_of_contra(Nat.is_eq(a,b),
    (h => candidates_conflict(f,p,motion,big,a,b,hf,ht,h)))

law scan_up_found:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +q: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,q) : Bool}
  {Bool.or(NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_up(f,p,motion,big,fuel,q,c)),
    Nat.is_eq(NavigationWordsImpl.scan_up(f,p,motion,big,fuel,q,c),799n)) == True{} : Bool}
def scan_up_found(f, p, motion, big, fuel, q, c, hc):
  match fuel:
    case 0n:
      or_true_r(NavigationWords.candidate(f,p,motion,big,799n))
    case 1n+k:
      match c:
        case True{}:
          %hc : {Bool.or(_, Nat.is_eq(q,799n)) == True{} : Bool}
          {==}
        case False{}:
          scan_up_found(f, p, motion, big, k, Nat.add(q,1n),
            NavigationWords.candidate(f,p,motion,big,Nat.add(q,1n)), {==})

law scan_up_inside:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +q: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,q) : Bool}
  {NavigationModel.inside(NavigationWordsImpl.scan_up(f,p,motion,big,fuel,q,c)) == True{} : Bool}
def scan_up_inside(f, p, motion, big, fuel, q, c, hc):
  match fuel:
    case 0n:
      {==}
    case 1n+k:
      match c:
        case True{}:
          candidate_inside(f,p,motion,big,q,
            Equal.sym(Bool, True{}, NavigationWords.candidate(f,p,motion,big,q), hc))
        case False{}:
          scan_up_inside(f, p, motion, big, k, Nat.add(q,1n),
            NavigationWords.candidate(f,p,motion,big,Nat.add(q,1n)), {==})

law scan_up_min:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +q: Nat
  for +q0: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,q) : Bool}
  for +hq: {NavigationWords.candidate(f,p,motion,big,q0) == True{} : Bool}
  for +hle: {Nat.is_le(q,q0) == True{} : Bool}
  for +hlt: {Nat.is_lt(q0, Nat.add(q,fuel)) == True{} : Bool}
  {Bool.and(
    NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_up(f,p,motion,big,fuel,q,c)),
    Nat.is_le(NavigationWordsImpl.scan_up(f,p,motion,big,fuel,q,c),q0)) == True{} : Bool}
def scan_up_min(f, p, motion, big, fuel, q, q0, c, hc, hq, hle, hlt):
  match fuel:
    case 0n:
      empty_elim({Bool.and(
        NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_up(f,p,motion,big,0n,q,c)),
        Nat.is_le(NavigationWordsImpl.scan_up(f,p,motion,big,0n,q,c),q0)) == True{} : Bool},
        absurd_eq(le_lt_absurd(q, q0, hle, lt_add_zero_r(q, q0, hlt))))
    case 1n+k:
      match c:
        case True{}:
          and_intro(NavigationWords.candidate(f,p,motion,big,q), Nat.is_le(q,q0),
            Equal.sym(Bool, True{}, NavigationWords.candidate(f,p,motion,big,q), hc), hle)
        case False{}:
          scan_up_min(f, p, motion, big, k, Nat.add(q,1n), q0,
            NavigationWords.candidate(f,p,motion,big,Nat.add(q,1n)), {==}, hq,
            succ_le_of_lt(q, q0,
              lt_of_le_ne(q, q0, hle,
                ne_of_candidates_conflict(f,p,motion,big,q,q0,
                  Equal.sym(Bool, False{}, NavigationWords.candidate(f,p,motion,big,q), hc),
                  hq))),
            lt_add_one_assoc(q, k, q0, hlt))

law scan_down_found:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(fuel)) : Bool}
  {Bool.or(NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_down(f,p,motion,big,fuel,c)),
    Nat.is_eq(NavigationWordsImpl.scan_down(f,p,motion,big,fuel,c),0n)) == True{} : Bool}
def scan_down_found(f, p, motion, big, fuel, c, hc):
  match fuel:
    case 0n:
      or_true_r(NavigationWords.candidate(f,p,motion,big,0n))
    case 1n++k:
      match c:
        case True{}:
          %hc : {Bool.or(_, Nat.is_eq(k,0n)) == True{} : Bool}
          {==}
        case False{}:
          scan_down_found(f, p, motion, big, k,
            NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(k)), {==})

law scan_down_inside:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(fuel)) : Bool}
  {NavigationModel.inside(NavigationWordsImpl.scan_down(f,p,motion,big,fuel,c)) == True{} : Bool}
def scan_down_inside(f, p, motion, big, fuel, c, hc):
  match fuel:
    case 0n:
      {==}
    case 1n++k:
      match c:
        case True{}:
          candidate_inside(f,p,motion,big,k,
            Equal.sym(Bool, True{}, NavigationWords.candidate(f,p,motion,big,k), hc))
        case False{}:
          scan_down_inside(f, p, motion, big, k,
            NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(k)), {==})

law scan_down_min:
  for +f: String
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for +fuel: Nat
  for +q0: Nat
  for +c: Bool
  for hc: {c == NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(fuel)) : Bool}
  for +hq: {NavigationWords.candidate(f,p,motion,big,q0) == True{} : Bool}
  for +hlt: {Nat.is_lt(q0, fuel) == True{} : Bool}
  {Bool.and(
    NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_down(f,p,motion,big,fuel,c)),
    Nat.is_ge(NavigationWordsImpl.scan_down(f,p,motion,big,fuel,c),q0)) == True{} : Bool}
def scan_down_min(f, p, motion, big, fuel, q0, c, hc, hq, hlt):
  match fuel:
    case 0n:
      empty_elim({Bool.and(
        NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.scan_down(f,p,motion,big,0n,c)),
        Nat.is_ge(NavigationWordsImpl.scan_down(f,p,motion,big,0n,c),q0)) == True{} : Bool},
        absurd_eq(Equal.trans(Bool, False{}, Nat.is_lt(q0,0n), True{},
          Equal.sym(Bool, Nat.is_lt(q0,0n), False{}, lt_zero(q0)), hlt)))
    case 1n++k:
      match c:
        case True{}:
          and_intro(NavigationWords.candidate(f,p,motion,big,k), Nat.is_ge(k,q0),
            Equal.sym(Bool, True{}, NavigationWords.candidate(f,p,motion,big,k), hc),
            ge_of_le(q0, k, le_pred_of_lt(q0, k, hlt)))
        case False{}:
          scan_down_min(f, p, motion, big, k, q0,
            NavigationWords.candidate(f,p,motion,big,NavigationWordsImpl.pred(k)), {==}, hq,
            lt_of_le_ne(q0, k, le_pred_of_lt(q0, k, hlt),
              is_ne_swap(k, q0,
                ne_of_candidates_conflict(f,p,motion,big,k,q0,
                  Equal.sym(Bool, False{}, NavigationWords.candidate(f,p,motion,big,k), hc),
                  hq))))

def selected_up_first(+f: String, +p: Nat, +motion: NavigationWords.Motion, +big: Bool) ->
  {Bool.and(
    NavigationModel.inside(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
      NavigationWords.candidate(f,p,motion,big,0n))),
    Bool.or(NavigationWords.candidate(f,p,motion,big,
      NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n))),
      Nat.is_eq(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
        NavigationWords.candidate(f,p,motion,big,0n)),799n))) == True{} : Bool}:
  and_intro(
    NavigationModel.inside(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
      NavigationWords.candidate(f,p,motion,big,0n))),
    Bool.or(NavigationWords.candidate(f,p,motion,big,
      NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n))),
      Nat.is_eq(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
        NavigationWords.candidate(f,p,motion,big,0n)),799n)),
    scan_up_inside(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n),{==}),
    scan_up_found(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n),{==}))

def selected_up_second(+f: String, +p: Nat, +motion: NavigationWords.Motion,
  +big: Bool, +q0: Nat) ->
  {Bool.or(Bool.not(NavigationWords.candidate(f,p,motion,big,q0)),
    Bool.and(NavigationWords.candidate(f,p,motion,big,
      NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n))),
      Nat.is_le(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
        NavigationWords.candidate(f,p,motion,big,0n)),q0))) == True{} : Bool}:
  or_not_min(NavigationWords.candidate(f,p,motion,big,q0),
    Bool.and(NavigationWords.candidate(f,p,motion,big,
      NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,NavigationWords.candidate(f,p,motion,big,0n))),
      Nat.is_le(NavigationWordsImpl.scan_up(f,p,motion,big,800n,0n,
        NavigationWords.candidate(f,p,motion,big,0n)),q0)),
    (+hq => scan_up_min(f,p,motion,big,800n,0n,q0,
      NavigationWords.candidate(f,p,motion,big,0n),{==},hq,zero_le(q0),
      candidate_inside(f,p,motion,big,q0,hq))))

def selected_down_first(+f: String, +p: Nat, +big: Bool) ->
  {Bool.and(
    NavigationModel.inside(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
      NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
    Bool.or(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,
      NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
      Nat.is_eq(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n)),0n))) == True{} : Bool}:
  and_intro(
    NavigationModel.inside(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
      NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
    Bool.or(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,
      NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
      Nat.is_eq(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n)),0n)),
    scan_down_inside(f,p,NavigationWords.Backward{},big,800n,
      NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n),{==}),
    scan_down_found(f,p,NavigationWords.Backward{},big,800n,
      NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n),{==}))

def selected_down_second(+f: String, +p: Nat, +big: Bool, +q0: Nat) ->
  {Bool.or(Bool.not(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,q0)),
    Bool.and(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,
      NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
      Nat.is_ge(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n)),q0))) == True{} : Bool}:
  or_not_min(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,q0),
    Bool.and(NavigationWords.candidate(f,p,NavigationWords.Backward{},big,
      NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n))),
      Nat.is_ge(NavigationWordsImpl.scan_down(f,p,NavigationWords.Backward{},big,800n,
        NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n)),q0)),
    (+hq => scan_down_min(f,p,NavigationWords.Backward{},big,800n,q0,
      NavigationWords.candidate(f,p,NavigationWords.Backward{},big,799n),{==},hq,
      candidate_inside(f,p,NavigationWords.Backward{},big,q0,hq))))

def NavigationWords.move(f, p, motion, big, count):
  NavigationWordsImpl.move_impl(count, f, p, motion, big)

def NavigationWords.one(f, p, motion, big, ok):
  match motion:
    case NavigationWords.Forward{}:
      ( selected_up_first(NavigationModel.contents(f),p,NavigationWords.Forward{},big),
        (q0 => selected_up_second(NavigationModel.contents(f),p,NavigationWords.Forward{},big,q0)) )
    case NavigationWords.Backward{}:
      ( selected_down_first(NavigationModel.contents(f),p,big),
        (q0 => selected_down_second(NavigationModel.contents(f),p,big,q0)) )
    case NavigationWords.End{}:
      ( selected_up_first(NavigationModel.contents(f),p,NavigationWords.End{},big),
        (q0 => selected_up_second(NavigationModel.contents(f),p,NavigationWords.End{},big,q0)) )

def NavigationWords.zero(f, p, motion, big):
  {==}

def NavigationWords.counted(f, p, motion, big, n, ok):
  {==}

law step_inside:
  for +field: NavigationModel.Field
  for +p: Nat
  for motion: NavigationWords.Motion
  for +big: Bool
  {NavigationModel.inside(NavigationWordsImpl.step(field,p,motion,big)) == True{} : Bool}
def step_inside(field, p, motion, big):
  match motion:
    case NavigationWords.Forward{}:
      scan_up_inside(NavigationModelImpl.norm(800n, field), p, NavigationWords.Forward{}, big,
        800n, 0n, NavigationWords.candidate(NavigationModelImpl.norm(800n, field), p,
          NavigationWords.Forward{}, big, 0n), {==})
    case NavigationWords.Backward{}:
      scan_down_inside(NavigationModelImpl.norm(800n, field), p, NavigationWords.Backward{}, big,
        800n, NavigationWords.candidate(NavigationModelImpl.norm(800n, field), p,
          NavigationWords.Backward{}, big, 799n), {==})
    case NavigationWords.End{}:
      scan_up_inside(NavigationModelImpl.norm(800n, field), p, NavigationWords.End{}, big,
        800n, 0n, NavigationWords.candidate(NavigationModelImpl.norm(800n, field), p,
          NavigationWords.End{}, big, 0n), {==})

law move_inside:
  for +n: Nat
  for +field: NavigationModel.Field
  for +p: Nat
  for +motion: NavigationWords.Motion
  for +big: Bool
  for ok: {NavigationModel.inside(p) == True{} : Bool}
  {NavigationModel.inside(NavigationWordsImpl.move_impl(n, field, p, motion, big)) == True{} : Bool}
def move_inside(n, field, p, motion, big, ok):
  match n:
    case 0n:
      ok
    case 1n+k:
      move_inside(k, field, NavigationWordsImpl.step(field,p,motion,big), motion, big,
        step_inside(field,p,motion,big))

def NavigationWords.bounded(f, p, motion, big, n, ok):
  move_inside(n, f, p, motion, big, ok)

def or_true_of_true_l(a: Bool, b: Bool, e: {a == True{} : Bool}) ->
  {Bool.or(a, b) == True{} : Bool}:
  Equal.trans(Bool, Bool.or(a,b), Bool.or(True{},b), True{},
    Equal.cong(Bool, Bool, (z => Bool.or(z,b)), a, True{}, e), {==})

def or_true_of_true_r(a: Bool, b: Bool, e: {b == True{} : Bool}) ->
  {Bool.or(a, b) == True{} : Bool}:
  Equal.trans(Bool, Bool.or(a,b), Bool.or(a,True{}), True{},
    Equal.cong(Bool, Bool, (z => Bool.or(a,z)), b, True{}, e), or_true_r(a))

def line_nonblank_congr(+text: String, +r: Nat, +a: Nat, +b: Nat,
  e: {a == b : Nat}) ->
  {NavigationLines.nonblank(text,r,a) == NavigationLines.nonblank(text,r,b) : Bool}:
  Equal.cong(Nat, Bool, (z => NavigationLines.nonblank(text,r,z)), a, b, e)

def line_nonblank_inside(+text: String, +r: Nat, +q: Nat,
  h: {NavigationLines.nonblank(text,r,q) == True{} : Bool}) ->
  {NavigationModel.inside(q) == True{} : Bool}:
  and_left(NavigationModel.inside(q),
    Bool.and(Nat.is_eq(NavigationModel.row(q),r),
      Bool.not(Char.is_eq(NavigationModel.text_at(text,q), ' '))), h)

def line_candidates_conflict(+text: String, +r: Nat, +a: Nat, +b: Nat,
  hf: {NavigationLines.nonblank(text,r,a) == False{} : Bool},
  ht: {NavigationLines.nonblank(text,r,b) == True{} : Bool},
  h: {Nat.is_eq(a,b) == True{} : Bool}) -> Empty:
  absurd_eq(Equal.trans(Bool, False{}, NavigationLines.nonblank(text,r,a), True{},
    Equal.sym(Bool, NavigationLines.nonblank(text,r,a), False{}, hf),
    Equal.trans(Bool, NavigationLines.nonblank(text,r,a),
      NavigationLines.nonblank(text,r,b), True{},
      line_nonblank_congr(text,r,a,b, is_eq_eq(a,b,h)), ht)))

def ne_of_line_candidates_conflict(+text: String, +r: Nat, +a: Nat, +b: Nat,
  hf: {NavigationLines.nonblank(text,r,a) == False{} : Bool},
  ht: {NavigationLines.nonblank(text,r,b) == True{} : Bool}) ->
  {Nat.is_ne(a,b) == True{} : Bool}:
  not_true_of_contra(Nat.is_eq(a,b),
    (h => line_candidates_conflict(text,r,a,b,hf,ht,h)))

law line_scan_indent:
  for +text: String
  for +r: Nat
  for +fuel: Nat
  for +q: Nat
  for +c: Bool
  for hc: {c == NavigationLines.nonblank(text,r,q) : Bool}
  for hr: {Nat.is_lt(r,20n) == True{} : Bool}
  {Bool.or(NavigationLines.nonblank(text,r,
      NavigationLinesImpl.scan_first(text,r,fuel,q,c)),
    Bool.and(NavigationModel.inside(
      NavigationLinesImpl.scan_first(text,r,fuel,q,c)),
      Nat.is_eq(NavigationLinesImpl.scan_first(text,r,fuel,q,c),
        NavigationModel.index(r,0n)))) == True{} : Bool}

def line_scan_indent(text, r, fuel, q, c, hc, hr):
  match fuel:
    case 0n:
      or_true_of_true_r(
        NavigationLines.nonblank(text,r,NavigationModel.index(r,0n)),
        Bool.and(NavigationModel.inside(NavigationModel.index(r,0n)),
          Nat.is_eq(NavigationModel.index(r,0n), NavigationModel.index(r,0n))),
        and_intro(NavigationModel.inside(NavigationModel.index(r,0n)),
          Nat.is_eq(NavigationModel.index(r,0n), NavigationModel.index(r,0n)),
          index_inside(r, 0n, hr, {==}),
          is_eq_refl(NavigationModel.index(r,0n))))
    case 1n+k:
      match c:
        case True{}:
          or_true_of_true_l(
            NavigationLines.nonblank(text,r,q),
            Bool.and(NavigationModel.inside(q),
              Nat.is_eq(q, NavigationModel.index(r,0n))),
            Equal.sym(Bool, True{}, NavigationLines.nonblank(text,r,q), hc))
        case False{}:
          line_scan_indent(text, r, k, Nat.add(q,1n),
            NavigationLines.nonblank(text,r,Nat.add(q,1n)), {==}, hr)

law line_scan_min:
  for +text: String
  for +r: Nat
  for +fuel: Nat
  for +q: Nat
  for +q0: Nat
  for +c: Bool
  for hc: {c == NavigationLines.nonblank(text,r,q) : Bool}
  for +hq: {NavigationLines.nonblank(text,r,q0) == True{} : Bool}
  for +hle: {Nat.is_le(q,q0) == True{} : Bool}
  for hlt: {Nat.is_lt(q0, Nat.add(q,fuel)) == True{} : Bool}
  {Bool.and(NavigationLines.nonblank(text,r,
      NavigationLinesImpl.scan_first(text,r,fuel,q,c)),
    Nat.is_le(NavigationLinesImpl.scan_first(text,r,fuel,q,c),q0)) == True{} : Bool}

def line_scan_min(text, r, fuel, q, q0, c, hc, hq, hle, hlt):
  match fuel:
    case 0n:
      empty_elim({Bool.and(NavigationLines.nonblank(text,r,
          NavigationLinesImpl.scan_first(text,r,0n,q,c)),
        Nat.is_le(NavigationLinesImpl.scan_first(text,r,0n,q,c),q0)) == True{} : Bool},
        absurd_eq(le_lt_absurd(q, q0, hle, lt_add_zero_r(q,q0,hlt))))
    case 1n+k:
      match c:
        case True{}:
          and_intro(NavigationLines.nonblank(text,r,q), Nat.is_le(q,q0),
            Equal.sym(Bool, True{}, NavigationLines.nonblank(text,r,q), hc), hle)
        case False{}:
          line_scan_min(text, r, k, Nat.add(q,1n), q0,
            NavigationLines.nonblank(text,r,Nat.add(q,1n)), {==}, hq,
            succ_le_of_lt(q, q0,
              lt_of_le_ne(q, q0, hle,
                ne_of_line_candidates_conflict(text,r,q,q0,
                  Equal.sym(Bool, False{}, NavigationLines.nonblank(text,r,q), hc),
                  hq))),
            lt_add_one_assoc(q, k, q0, hlt))

law line_scan_inside:
  for +text: String
  for +r: Nat
  for +fuel: Nat
  for +q: Nat
  for +c: Bool
  for hc: {c == NavigationLines.nonblank(text,r,q) : Bool}
  for hr: {Nat.is_lt(r,20n) == True{} : Bool}
  {NavigationModel.inside(NavigationLinesImpl.scan_first(text,r,fuel,q,c)) ==
    True{} : Bool}

def line_scan_inside(text, r, fuel, q, c, hc, hr):
  match fuel:
    case 0n:
      index_inside(r, 0n, hr, {==})
    case 1n+k:
      match c:
        case True{}:
          line_nonblank_inside(text, r, q,
            Equal.sym(Bool, True{}, NavigationLines.nonblank(text,r,q), hc))
        case False{}:
          line_scan_inside(text, r, k, Nat.add(q,1n),
            NavigationLines.nonblank(text,r,Nat.add(q,1n)), {==}, hr)

def line_indent_selected(+text: String, +r: Nat,
  hr: {Nat.is_lt(r,20n) == True{} : Bool}) ->
  NavigationLines.IndentSelected(text, r, NavigationLinesImpl.first_nonblank(text,r)):
  ( line_scan_indent(text,r,800n,0n,NavigationLines.nonblank(text,r,0n),{==},hr),
    (q0 => or_not_min(NavigationLines.nonblank(text,r,q0),
      Bool.and(NavigationLines.nonblank(text,r,
        NavigationLinesImpl.first_nonblank(text,r)),
        Nat.is_le(NavigationLinesImpl.first_nonblank(text,r),q0)),
      (+hq => line_scan_min(text,r,800n,0n,q0,NavigationLines.nonblank(text,r,0n),
        {==},hq,zero_le(q0),line_nonblank_inside(text,r,q0,hq)))) ))

def NavigationLines.zero_column(f, p, n, ok):
  {==}

def NavigationLines.row_end(f, p, n, ok):
  {==}

def NavigationLines.first_nonblank(f, p, n, ok):
  line_indent_selected(NavigationModel.contents(f), NavigationModel.row(p),
    row_lt_20(p, ok))

def NavigationLines.first_row(f, p, n, ok):
  line_indent_selected(NavigationModel.contents(f),
    NavigationLines.target_row(p, NavigationLines.FirstRow{}, n),
    min_lt(19n, Nat.sub(n,1n), 20n, {==}))

def NavigationLines.last_row(f, p, n, ok):
  line_indent_selected(NavigationModel.contents(f),
    NavigationLines.target_row(p, NavigationLines.LastRow{}, n),
    min_lt(19n, Nat.sub(Nat.add(n,
      Nat.mul(20n, NavigationModel.bit(Nat.is_eq(n,0n)))),1n), 20n, {==}))

def line_bounded(+f: NavigationModel.Field, +p: Nat, motion: NavigationLines.Motion,
  +n: Nat, ok: {NavigationModel.inside(p) == True{} : Bool}) ->
  {NavigationModel.inside(NavigationLinesImpl.move_impl(f,p,motion,n)) ==
    True{} : Bool}:
  match motion:
    case NavigationLines.ColumnZero{}:
      index_inside(NavigationModel.row(p), 0n, row_lt_20(p, ok), {==})
    case NavigationLines.FirstNonblank{}:
      line_scan_inside(NavigationModelImpl.norm(800n, f), NavigationModel.row(p),
        800n, 0n, NavigationLines.nonblank(NavigationModelImpl.norm(800n, f),
          NavigationModel.row(p), 0n), {==}, row_lt_20(p, ok))
    case NavigationLines.RowEnd{}:
      index_inside(NavigationLines.target_row(p, NavigationLines.RowEnd{}, n), 39n,
        min_lt(19n, Nat.add(NavigationModel.row(p),
          Nat.sub(NavigationModel.effective(n),1n)), 20n, {==}), {==})
    case NavigationLines.FirstRow{}:
      line_scan_inside(NavigationModelImpl.norm(800n, f),
        NavigationLines.target_row(p, NavigationLines.FirstRow{}, n),
        800n, 0n, NavigationLines.nonblank(NavigationModelImpl.norm(800n, f),
          NavigationLines.target_row(p, NavigationLines.FirstRow{}, n), 0n),
        {==}, min_lt(19n, Nat.sub(n,1n), 20n, {==}))
    case NavigationLines.LastRow{}:
      line_scan_inside(NavigationModelImpl.norm(800n, f),
        NavigationLines.target_row(p, NavigationLines.LastRow{}, n),
        800n, 0n, NavigationLines.nonblank(NavigationModelImpl.norm(800n, f),
          NavigationLines.target_row(p, NavigationLines.LastRow{}, n), 0n),
        {==}, min_lt(19n, Nat.sub(Nat.add(n,
          Nat.mul(20n, NavigationModel.bit(Nat.is_eq(n,0n)))),1n), 20n, {==}))

def NavigationLines.bounded(f, p, motion, n, ok):
  line_bounded(f, p, motion, n, ok)

law le_add_mono:
  for +c: Nat
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_le(a,b) == True{} : Bool}
  {Nat.is_le(Nat.add(c,a), Nat.add(c,b)) == True{} : Bool}

def le_add_mono(c, a, b, h):
  match c:
    case 0n:
      h
    case 1n+k:
      le_add_mono(k, a, b, h)

law lt_add_mono:
  for +c: Nat
  for +a: Nat
  for +b: Nat
  for h: {Nat.is_lt(a,b) == True{} : Bool}
  {Nat.is_lt(Nat.add(c,a), Nat.add(c,b)) == True{} : Bool}

def lt_add_mono(c, a, b, h):
  match c:
    case 0n:
      h
    case 1n+k:
      lt_add_mono(k, a, b, h)

def lt_of_lt_le(a: Nat, b: Nat, c: Nat,
  hab: {Nat.is_lt(a,b) == True{} : Bool},
  hbc: {Nat.is_le(b,c) == True{} : Bool}) -> {Nat.is_lt(a,c) == True{} : Bool}:
  match a b c:
    case a 0n c:
      empty_elim({Nat.is_lt(a,c) == True{} : Bool}, false_elim(a, hab))
    case a 1n+pb 0n:
      empty_elim({Nat.is_lt(a,0n) == True{} : Bool}, false_elim(1n+pb, hbc))
    case 0n 1n+pb 1n+pc:
      {==}
    case 1n+pa 1n+pb 1n+pc:
      lt_of_lt_le(pa, pb, pc, hab, hbc)

law le_refl_nat:
  for +a: Nat
  {Nat.is_le(a,a) == True{} : Bool}

def le_refl_nat(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      le_refl_nat(p)

def le_of_eq_nat(+a: Nat, +b: Nat, e: {a == b : Nat}) -> {Nat.is_le(a,b) == True{} : Bool}:
  %e : {Nat.is_le(a,_) == True{} : Bool}
  le_refl_nat(a)

law lt_add_one_l:
  for +a: Nat
  {Nat.is_lt(a, Nat.add(1n,a)) == True{} : Bool}

def lt_add_one_l(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      lt_add_one_l(p)

def false_of_contra(b: Bool, h: {b == True{} : Bool} -> Empty) -> {b == False{} : Bool}:
  match b:
    case False{}:
      {==}
    case True{}:
      empty_elim({True{} == False{} : Bool}, h({==}))

def not_le_of_lt(+a: Nat, +b: Nat, h: {Nat.is_lt(b,a) == True{} : Bool}) ->
  {Nat.is_le(a,b) == False{} : Bool}:
  false_of_contra(Nat.is_le(a,b),
    (hle => absurd_eq(le_lt_absurd(a,b,hle,h))))

def and_false_r(a: Bool) -> {Bool.and(a,False{}) == False{} : Bool}:
  match a:
    case False{}:
      {==}
    case True{}:
      {==}

def and_true_r(a: Bool) -> {Bool.and(a,True{}) == a : Bool}:
  match a:
    case False{}:
      {==}
    case True{}:
      {==}

def index_le_mono(r: Nat, i: Nat, j: Nat, h: {Nat.is_le(i,j) == True{} : Bool}) ->
  {Nat.is_le(NavigationModel.index(r,i), NavigationModel.index(r,j)) == True{} : Bool}:
  le_add_mono(Nat.mul(r,40n), i, j, h)

def index_lt_mono(r: Nat, i: Nat, j: Nat, h: {Nat.is_lt(i,j) == True{} : Bool}) ->
  {Nat.is_lt(NavigationModel.index(r,i), NavigationModel.index(r,j)) == True{} : Bool}:
  lt_add_mono(Nat.mul(r,40n), i, j, h)

def within_suffix_true(+r: Nat, +i: Nat, +j: Nat, h: {Nat.is_le(j,i) == True{} : Bool}) ->
  {NavigationFind.within(NavigationModel.index(r,i), NavigationModel.index(r,j)) == True{} : Bool}:
  ge_of_le(NavigationModel.index(r,j), NavigationModel.index(r,i), index_le_mono(r,j,i,h))

def within_suffix_false(+r: Nat, +i: Nat, +j: Nat, h: {Nat.is_lt(i,j) == True{} : Bool}) ->
  {NavigationFind.within(NavigationModel.index(r,i), NavigationModel.index(r,j)) == False{} : Bool}:
  Equal.trans(Bool, Nat.is_ge(NavigationModel.index(r,i), NavigationModel.index(r,j)),
    Nat.is_le(NavigationModel.index(r,j), NavigationModel.index(r,i)), False{},
    le_ge_swap(NavigationModel.index(r,i), NavigationModel.index(r,j)),
    not_le_of_lt(NavigationModel.index(r,j), NavigationModel.index(r,i), index_lt_mono(r,i,j,h)))

def within_zero_true(+i: Nat) -> {NavigationFind.within(i, 0n) == True{} : Bool}:
  ge_of_le(0n, i, zero_le(i))

def and_congr_r(a: Bool, b1: Bool, b2: Bool, e: {b1 == b2 : Bool}) ->
  {Bool.and(a,b1) == Bool.and(a,b2) : Bool}:
  Equal.cong(Bool, Bool, (z => Bool.and(a,z)), b1, b2, e)

def bit_congr(b1: Bool, b2: Bool, e: {b1 == b2 : Bool}) ->
  {NavigationModel.bit(b1) == NavigationModel.bit(b2) : Nat}:
  Equal.cong(Bool, Nat, (z => NavigationModel.bit(z)), b1, b2, e)

def add_congr_l(a1: Nat, a2: Nat, +b: Nat, e: {a1 == a2 : Nat}) ->
  {Nat.add(a1,b) == Nat.add(a2,b) : Nat}:
  Equal.cong(Nat, Nat, (z => Nat.add(z,b)), a1, a2, e)

def add_congr_r(+a: Nat, b1: Nat, b2: Nat, e: {b1 == b2 : Nat}) ->
  {Nat.add(a,b1) == Nat.add(a,b2) : Nat}:
  Equal.cong(Nat, Nat, (z => Nat.add(a,z)), b1, b2, e)

law hits_zero_below:
  for +fuel: Nat
  for +text: String
  for +p: Nat
  for +j: Nat
  for +target: Char
  for +right: Bool
  for hle: {Nat.is_le(fuel,j) == True{} : Bool}
  {NavigationFind.hits(fuel,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right) == 0n : Nat}

def hits_zero_below(fuel,text,p,j,target,right,hle):
  match fuel:
    case 0n:
      {==}
    case 1n++i:
      +hilt = lt_of_lt_le(i, 1n+i, j, lt_add_one_l(i), hle)
      +hlei = le_of_lt(i,j, hilt)
      Equal.trans(Nat,
        NavigationFind.hits(1n+i,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right),
        Nat.add(NavigationModel.bit(False{}), NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right)),
        0n,
        add_congr_l(NavigationModel.bit(Bool.and(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right),
            NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), NavigationModel.index(NavigationModel.row(p),j)))),
          NavigationModel.bit(False{}),
          NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right),
          bit_congr(Bool.and(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right),
              NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), NavigationModel.index(NavigationModel.row(p),j))),
            False{},
            Equal.trans(Bool,
              Bool.and(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right),
                NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), NavigationModel.index(NavigationModel.row(p),j))),
              Bool.and(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right), False{}),
              False{},
              and_congr_r(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right),
                NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), NavigationModel.index(NavigationModel.row(p),j)), False{},
                within_suffix_false(NavigationModel.row(p), i, j, hilt)),
              and_false_r(NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),i),target,right))))),
        Equal.trans(Nat,
          Nat.add(NavigationModel.bit(False{}), NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right)),
          Nat.add(NavigationModel.bit(False{}), 0n),
          0n,
          add_congr_r(NavigationModel.bit(False{}),
            NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),j),target,right), 0n,
            hits_zero_below(i,text,p,j,target,right, hlei)),
          {==}))

def and_congr_l(a1: Bool, a2: Bool, b: Bool, e: {a1 == a2 : Bool}) ->
  {Bool.and(a1,b) == Bool.and(a2,b) : Bool}:
  Equal.cong(Bool, Bool, (z => Bool.and(z,b)), a1, a2, e)

def hit_at(+text: String, +p: Nat, +i: Nat, +target: Char, +right: Bool) -> Bool:
  NavigationFind.hit(text, p, NavigationModel.index(NavigationModel.row(p), i), target, right)

def hits_step_false(+i: Nat, +text: String, +p: Nat, +q: Nat, +target: Char, +right: Bool,
  hhit: {hit_at(text,p,i,target,right) == False{} : Bool}) ->
  {NavigationFind.hits(1n+i,text,p,q,target,right) == NavigationFind.hits(i,text,p,q,target,right) : Nat}:
  Equal.trans(Nat, NavigationFind.hits(1n+i,text,p,q,target,right),
    Nat.add(NavigationModel.bit(Bool.and(False{}, NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q))),
      NavigationFind.hits(i,text,p,q,target,right)),
    NavigationFind.hits(i,text,p,q,target,right),
    add_congr_l(NavigationModel.bit(Bool.and(hit_at(text,p,i,target,right), NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q))),
      NavigationModel.bit(Bool.and(False{}, NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q))),
      NavigationFind.hits(i,text,p,q,target,right),
      bit_congr(Bool.and(hit_at(text,p,i,target,right), NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q)),
        Bool.and(False{}, NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q)),
        and_congr_l(hit_at(text,p,i,target,right), False{},
          NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q), hhit))),
    {==})

def hits_step_true(+i: Nat, +text: String, +p: Nat, +q: Nat, +target: Char, +right: Bool,
  hhit: {hit_at(text,p,i,target,right) == True{} : Bool},
  hw: {NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q) == True{} : Bool}) ->
  {NavigationFind.hits(1n+i,text,p,q,target,right) == Nat.add(1n, NavigationFind.hits(i,text,p,q,target,right)) : Nat}:
  Equal.trans(Nat, NavigationFind.hits(1n+i,text,p,q,target,right),
    Nat.add(NavigationModel.bit(Bool.and(True{}, True{})), NavigationFind.hits(i,text,p,q,target,right)),
    Nat.add(1n, NavigationFind.hits(i,text,p,q,target,right)),
    add_congr_l(NavigationModel.bit(Bool.and(hit_at(text,p,i,target,right), NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q))),
      NavigationModel.bit(Bool.and(True{}, True{})),
      NavigationFind.hits(i,text,p,q,target,right),
      bit_congr(Bool.and(hit_at(text,p,i,target,right), NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q)),
        Bool.and(True{}, True{}),
        Equal.trans(Bool,
          Bool.and(hit_at(text,p,i,target,right), NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q)),
          Bool.and(True{}, NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q)),
          Bool.and(True{}, True{}),
          and_congr_l(hit_at(text,p,i,target,right), True{},
            NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q), hhit),
          and_congr_r(True{}, NavigationFind.within(NavigationModel.index(NavigationModel.row(p),i), q), True{}, hw)))),
    {==})

def ScanComplete(+fuel: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +r: Nat, +c: Bool) -> Type:
  &j: Nat -> (
    {NavigationFindImpl.scan(fuel,text,p,target,right,r,c) == NavigationFindImpl.Found{j} : NavigationFindImpl.Search}
    & ({NavigationFind.hit(text,p,j,target,right) == True{} : Bool}
    & ({NavigationFind.hits(fuel,text,p,j,target,right) == r : Nat}
    & ({Nat.is_lt(j, NavigationModel.index(NavigationModel.row(p),fuel)) == True{} : Bool}
    & {c == hit_at(text,p,NavigationFindImpl.pred(fuel),target,right) : Bool}))))

def scan_congr_c(+fuel: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +r: Nat, c1: Bool, c2: Bool, e: {c1 == c2 : Bool}) ->
  {NavigationFindImpl.scan(fuel,text,p,target,right,r,c1) == NavigationFindImpl.scan(fuel,text,p,target,right,r,c2) : NavigationFindImpl.Search}:
  Equal.cong(Bool, NavigationFindImpl.Search, (z => NavigationFindImpl.scan(fuel,text,p,target,right,r,z)), c1, c2, e)

def within_above_true(+r: Nat, +i: Nat, +pos: Nat,
  h: {Nat.is_lt(pos, NavigationModel.index(r,i)) == True{} : Bool}) ->
  {NavigationFind.within(NavigationModel.index(r,i), pos) == True{} : Bool}:
  ge_of_le(pos, NavigationModel.index(r,i), le_of_lt(pos, NavigationModel.index(r,i), h))

def below_succ(+pos: Nat, +r: Nat, +i: Nat,
  h: {Nat.is_lt(pos, NavigationModel.index(r,i)) == True{} : Bool}) ->
  {Nat.is_lt(pos, NavigationModel.index(r, 1n+i)) == True{} : Bool}:
  lt_of_lt_le(pos, NavigationModel.index(r,i), NavigationModel.index(r,1n+i), h,
    index_le_mono(r, i, 1n+i, le_of_lt(i, 1n+i, lt_add_one_l(i))))

def match_head_false(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  hhit: {hit_at(text,p,i,target,right) == False{} : Bool}) ->
  {False{} == hit_at(text,p,i,target,right) : Bool}:
  Equal.sym(Bool, hit_at(text,p,i,target,right), False{}, hhit)

def match_head_true(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  hhit: {hit_at(text,p,i,target,right) == True{} : Bool}) ->
  {True{} == hit_at(text,p,i,target,right) : Bool}:
  Equal.sym(Bool, hit_at(text,p,i,target,right), True{}, hhit)

def complete_true_zero(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  hhit: {hit_at(text,p,i,target,right) == True{} : Bool}) ->
  ScanComplete(1n+i,text,p,target,right,1n,True{}):
  +hh = hhit
  ( NavigationModel.index(NavigationModel.row(p),i),
    ( {==},
      ( hh,
        ( Equal.trans(Nat,
            NavigationFind.hits(1n+i,text,p,NavigationModel.index(NavigationModel.row(p),i),target,right),
            Nat.add(1n, NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),i),target,right)),
            1n,
            hits_step_true(i,text,p,NavigationModel.index(NavigationModel.row(p),i),target,right,hh,
              within_suffix_true(NavigationModel.row(p),i,i,le_refl_nat(i))),
            Equal.trans(Nat,
              Nat.add(1n, NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),i),target,right)),
              Nat.add(1n, 0n),
              1n,
              add_congr_r(1n, NavigationFind.hits(i,text,p,NavigationModel.index(NavigationModel.row(p),i),target,right), 0n,
                hits_zero_below(i,text,p,i,target,right,le_refl_nat(i))),
              {==}) ),
          ( index_lt_mono(NavigationModel.row(p), i, 1n+i, lt_add_one_l(i)),
            match_head_true(i,text,p,target,right,hh) ) ) ) ) )

def complete_false_zero(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +c_next: Bool,
  hhit: {hit_at(text,p,i,target,right) == False{} : Bool},
  tail: ScanComplete(i,text,p,target,right,1n,c_next)) ->
  ScanComplete(1n+i,text,p,target,right,1n,False{}):
  match tail:
    case (+j, (scan_eq, (hit_eq, (hits_eq, (+below_eq, match_eq))))):
      +hh = hhit
      ( j,
        ( Equal.trans(NavigationFindImpl.Search, NavigationFindImpl.scan(1n+i,text,p,target,right,1n,False{}),
            NavigationFindImpl.scan(i,text,p,target,right,1n,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
            NavigationFindImpl.Found{j},
            {==},
            Equal.trans(NavigationFindImpl.Search,
              NavigationFindImpl.scan(i,text,p,target,right,1n,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
              NavigationFindImpl.scan(i,text,p,target,right,1n,c_next),
              NavigationFindImpl.Found{j},
              scan_congr_c(i,text,p,target,right,1n,
                hit_at(text,p,NavigationFindImpl.pred(i),target,right), c_next, Equal.sym(Bool, c_next, hit_at(text,p,NavigationFindImpl.pred(i),target,right), match_eq)),
              scan_eq)),
          ( hit_eq,
            ( Equal.trans(Nat, NavigationFind.hits(1n+i,text,p,j,target,right),
                NavigationFind.hits(i,text,p,j,target,right), 1n,
                hits_step_false(i,text,p,j,target,right,hh), hits_eq),
              ( below_succ(j,NavigationModel.row(p),i,below_eq),
                match_head_false(i,text,p,target,right,hh) ) ) ) ) )

def complete_false_more(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +q2: Nat, +c_next: Bool,
  hhit: {hit_at(text,p,i,target,right) == False{} : Bool},
  tail: ScanComplete(i,text,p,target,right,2n+q2,c_next)) ->
  ScanComplete(1n+i,text,p,target,right,2n+q2,False{}):
  match tail:
    case (+j, (scan_eq, (hit_eq, (hits_eq, (+below_eq, match_eq))))):
      +hh = hhit
      ( j,
        ( Equal.trans(NavigationFindImpl.Search, NavigationFindImpl.scan(1n+i,text,p,target,right,2n+q2,False{}),
            NavigationFindImpl.scan(i,text,p,target,right,2n+q2,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
            NavigationFindImpl.Found{j},
            {==},
            Equal.trans(NavigationFindImpl.Search,
              NavigationFindImpl.scan(i,text,p,target,right,2n+q2,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
              NavigationFindImpl.scan(i,text,p,target,right,2n+q2,c_next),
              NavigationFindImpl.Found{j},
              scan_congr_c(i,text,p,target,right,2n+q2,
                hit_at(text,p,NavigationFindImpl.pred(i),target,right), c_next, Equal.sym(Bool, c_next, hit_at(text,p,NavigationFindImpl.pred(i),target,right), match_eq)),
              scan_eq)),
          ( hit_eq,
            ( Equal.trans(Nat, NavigationFind.hits(1n+i,text,p,j,target,right),
                NavigationFind.hits(i,text,p,j,target,right), 2n+q2,
                hits_step_false(i,text,p,j,target,right,hh), hits_eq),
              ( below_succ(j,NavigationModel.row(p),i,below_eq),
                match_head_false(i,text,p,target,right,hh) ) ) ) ) )

def complete_true_more(+i: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +q2: Nat, +c_next: Bool,
  hhit: {hit_at(text,p,i,target,right) == True{} : Bool},
  tail: ScanComplete(i,text,p,target,right,1n+q2,c_next)) ->
  ScanComplete(1n+i,text,p,target,right,2n+q2,True{}):
  match tail:
    case (+j, (scan_eq, (hit_eq, (hits_eq, (+below_eq, match_eq))))):
      +hh = hhit
      ( j,
        ( Equal.trans(NavigationFindImpl.Search, NavigationFindImpl.scan(1n+i,text,p,target,right,2n+q2,True{}),
            NavigationFindImpl.scan(i,text,p,target,right,1n+q2,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
            NavigationFindImpl.Found{j},
            {==},
            Equal.trans(NavigationFindImpl.Search,
              NavigationFindImpl.scan(i,text,p,target,right,1n+q2,hit_at(text,p,NavigationFindImpl.pred(i),target,right)),
              NavigationFindImpl.scan(i,text,p,target,right,1n+q2,c_next),
              NavigationFindImpl.Found{j},
              scan_congr_c(i,text,p,target,right,1n+q2,
                hit_at(text,p,NavigationFindImpl.pred(i),target,right), c_next, Equal.sym(Bool, c_next, hit_at(text,p,NavigationFindImpl.pred(i),target,right), match_eq)),
              scan_eq)),
          ( hit_eq,
            ( Equal.trans(Nat, NavigationFind.hits(1n+i,text,p,j,target,right),
                Nat.add(1n, NavigationFind.hits(i,text,p,j,target,right)), 2n+q2,
                hits_step_true(i,text,p,j,target,right,hh,
                  within_above_true(NavigationModel.row(p),i,j,below_eq)),
                Equal.trans(Nat,
                  Nat.add(1n, NavigationFind.hits(i,text,p,j,target,right)),
                  Nat.add(1n, 1n+q2), 2n+q2,
                  add_congr_r(1n, NavigationFind.hits(i,text,p,j,target,right), 1n+q2, hits_eq),
                  {==})),
              ( below_succ(j,NavigationModel.row(p),i,below_eq),
                match_head_true(i,text,p,target,right,hh) ) ) ) ) )

def le_transport_r(+a: Nat, b1: Nat, b2: Nat,
  h: {Nat.is_le(a,b1) == True{} : Bool},
  e: {b2 == b1 : Nat}) -> {Nat.is_le(a,b2) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_le(a,b2), Nat.is_le(a,b1), True{},
    Equal.cong(Nat, Bool, (z => Nat.is_le(a,z)), b2, b1, e), h)

def one_le_one_add(+q2: Nat) -> {Nat.is_le(1n, 1n+q2) == True{} : Bool}:
  match q2:
    case 0n:
      {==}
    case 1n+k:
      {==}

def scan_complete(+fuel: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  +r: Nat, +c: Bool,
  hc: {c == hit_at(text,p,NavigationFindImpl.pred(fuel),target,right) : Bool},
  hr: {Nat.is_le(1n,r) == True{} : Bool},
  hle: {Nat.is_le(r, NavigationFind.hits(fuel,text,p,NavigationFind.limit(right),target,right)) == True{} : Bool}) ->
  ScanComplete(fuel,text,p,target,right,r,c):
  match fuel:
    case 0n:
      match r:
        case 0n:
          empty_elim(ScanComplete(0n,text,p,target,right,0n,c), absurd_eq(hr))
        case 1n+k:
          empty_elim(ScanComplete(0n,text,p,target,right,1n+k,c), absurd_eq(hle))
    case 1n++i:
      match r:
        case 0n:
          empty_elim(ScanComplete(1n+i,text,p,target,right,0n,c), absurd_eq(hr))
        case 1n++q:
          match q:
            case 0n:
              match c:
                case True{}:
                  complete_true_zero(i,text,p,target,right,
                    Equal.sym(Bool, True{}, hit_at(text,p,i,target,right), hc))
                case False{}:
                  +hh = Equal.sym(Bool, False{}, hit_at(text,p,i,target,right), hc)
                  +hle_tail = le_transport_r(1n, NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                    NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right), hle,
                    Equal.sym(Nat, NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                      NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right),
                      hits_step_false(i,text,p,NavigationFind.limit(right),target,right,hh)))
                  complete_false_zero(i,text,p,target,right,
                    hit_at(text,p,NavigationFindImpl.pred(i),target,right), hh,
                    scan_complete(i,text,p,target,right,1n,
                      hit_at(text,p,NavigationFindImpl.pred(i),target,right), {==}, le_refl_nat(1n), hle_tail))
            case 1n++q2:
              match c:
                case True{}:
                  +hh = Equal.sym(Bool, True{}, hit_at(text,p,i,target,right), hc)
                  +hle_raw = le_transport_r(2n+q2,
                    NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                    Nat.add(1n, NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right)), hle,
                    Equal.sym(Nat, NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                      Nat.add(1n, NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right)),
                      hits_step_true(i,text,p,NavigationFind.limit(right),target,right,hh,
                        within_zero_true(NavigationModel.index(NavigationModel.row(p),i)))))
                  complete_true_more(i,text,p,target,right,q2,
                    hit_at(text,p,NavigationFindImpl.pred(i),target,right), hh,
                    scan_complete(i,text,p,target,right,1n+q2,
                      hit_at(text,p,NavigationFindImpl.pred(i),target,right), {==}, one_le_one_add(q2), hle_raw))
                case False{}:
                  +hh = Equal.sym(Bool, False{}, hit_at(text,p,i,target,right), hc)
                  +hle_tail = le_transport_r(2n+q2,
                    NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                    NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right), hle,
                    Equal.sym(Nat, NavigationFind.hits(1n+i,text,p,NavigationFind.limit(right),target,right),
                      NavigationFind.hits(i,text,p,NavigationFind.limit(right),target,right),
                      hits_step_false(i,text,p,NavigationFind.limit(right),target,right,hh)))
                  complete_false_more(i,text,p,target,right,q2,
                    hit_at(text,p,NavigationFindImpl.pred(i),target,right), hh,
                    scan_complete(i,text,p,target,right,2n+q2,
                      hit_at(text,p,NavigationFindImpl.pred(i),target,right), {==}, hr, hle_tail))

law le_trans_nat:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  for hab: {Nat.is_le(a,b) == True{} : Bool}
  for hbc: {Nat.is_le(b,c) == True{} : Bool}
  {Nat.is_le(a,c) == True{} : Bool}

def le_trans_nat(a,b,c,hab,hbc):
  match a b c:
    case 0n b c:
      match c:
        case 0n:
          {==}
        case 1n+pc:
          {==}
    case 1n+pa b c:
      match b:
        case 0n:
          empty_elim({Nat.is_le(1n+pa,c)==True{} : Bool}, false_elim(1n+pa,hab))
        case 1n+pb:
          match c:
            case 0n:
              empty_elim({Nat.is_le(1n+pa,0n)==True{} : Bool}, false_elim(1n+pb,hbc))
            case 1n+pc:
              le_trans_nat(pa,pb,pc,hab,hbc)

def le_succ_l(+a: Nat) -> {Nat.is_le(a, 1n+a) == True{} : Bool}:
  le_of_lt(a, 1n+a, lt_add_one_l(a))

law sub_zero_r:
  for +a: Nat
  {Nat.sub(a,0n) == a : Nat}

def sub_zero_r(a):
  match a:
    case 0n:
      {==}
    case 1n+p:
      {==}

law sub_plus_one_le_total:
  for +total: Nat
  for +count: Nat
  for hcount: {Nat.is_le(1n,count) == True{} : Bool}
  for hle: {Nat.is_le(count,total) == True{} : Bool}
  {Nat.is_le(Nat.add(Nat.sub(total,count),1n), total) == True{} : Bool}

def sub_plus_one_le_total(total,count,hcount,hle):
  match total count:
    case 0n 0n:
      empty_elim({Nat.is_le(Nat.add(Nat.sub(0n,0n),1n),0n)==True{} : Bool},
        absurd_eq(hcount))
    case 0n 1n+pc:
      empty_elim({Nat.is_le(Nat.add(Nat.sub(0n,1n+pc),1n),0n)==True{} : Bool},
        absurd_eq(hle))
    case 1n+pt 0n:
      empty_elim({Nat.is_le(Nat.add(Nat.sub(1n+pt,0n),1n),1n+pt)==True{} : Bool},
        absurd_eq(hcount))
    case 1n+pt 1n+pc:
      match pc:
        case 0n:
          Equal.trans(Bool,
            Nat.is_le(Nat.add(Nat.sub(1n+pt,1n),1n),1n+pt),
            Nat.is_le(Nat.add(pt,1n),1n+pt),
            True{},
            Equal.cong(Nat,Bool,(z=>Nat.is_le(Nat.add(z,1n),1n+pt)),
              Nat.sub(1n+pt,1n), pt,
              Equal.trans(Nat, Nat.sub(1n+pt,1n), Nat.sub(pt,0n), pt,
                {==}, sub_zero_r(pt))),
            Equal.trans(Bool,
              Nat.is_le(Nat.add(pt,1n),1n+pt),
              Nat.is_le(Nat.add(1n,pt),1n+pt),
              True{},
              Equal.cong(Nat,Bool,(z=>Nat.is_le(z,1n+pt)),
                Nat.add(pt,1n), Nat.add(1n,pt), add_comm(pt,1n)),
              le_refl_nat(1n+pt)))
        case 1n+pc2:
          le_trans_nat(Nat.add(Nat.sub(pt,1n+pc2),1n), pt, 1n+pt,
            sub_plus_one_le_total(pt, 1n+pc2, one_le_one_add(pc2), hle),
            le_succ_l(pt))

def make_zero_positive(+x: Nat) -> {Nat.is_le(1n, Nat.add(x,1n)) == True{} : Bool}:
  succ_le_of_lt(0n, Nat.add(x,1n), zero_lt_add_one(x))

def rank_positive(right: Bool, +count: Nat, +total: Nat,
  hcount: {Nat.is_le(1n,count) == True{} : Bool}) ->
  {Nat.is_le(1n, NavigationFind.rank(right,count,total)) == True{} : Bool}:
  match right:
    case True{}:
      make_zero_positive(Nat.sub(total,count))
    case False{}:
      hcount



def rank_le_total(right: Bool, +count: Nat, +total: Nat,
  hcount: {Nat.is_le(1n,count) == True{} : Bool},
  hle: {Nat.is_le(count,total) == True{} : Bool}) ->
  {Nat.is_le(NavigationFind.rank(right,count,total), total) == True{} : Bool}:
  match right:
    case True{}:
      sub_plus_one_le_total(total,count,hcount,hle)
    case False{}:
      hle

def cmp_gt_of_not_le(c: Cmp, h: {Cmp.is_le(c) == False{} : Bool}) ->
  {Cmp.is_gt(c) == True{} : Bool}:
  match c:
    case LT{}:
      empty_elim({Cmp.is_gt(LT{}) == True{} : Bool}, absurd_eq(Equal.sym(Bool, True{}, False{}, h)))
    case EQ{}:
      empty_elim({Cmp.is_gt(EQ{}) == True{} : Bool}, absurd_eq(Equal.sym(Bool, True{}, False{}, h)))
    case GT{}:
      {==}

def gt_of_not_le(+a: Nat, +b: Nat, h: {Nat.is_le(a,b) == False{} : Bool}) ->
  {Nat.is_gt(a,b) == True{} : Bool}:
  cmp_gt_of_not_le(Nat.cmp(a,b), h)

def NavigationFind.zero(f, p, target, right):
  {==}

def find_pick_found(p: Nat, j: Nat) ->
  {NavigationFindImpl.pick(p, NavigationFindImpl.Found{j}) == j : Nat}:
  {==}

def find_pick_congr(p: Nat, res1: NavigationFindImpl.Search, res2: NavigationFindImpl.Search,
  e: {res1 == res2 : NavigationFindImpl.Search}) ->
  {NavigationFindImpl.pick(p,res1) == NavigationFindImpl.pick(p,res2) : Nat}:
  Equal.cong(NavigationFindImpl.Search, Nat, (z => NavigationFindImpl.pick(p,z)), res1, res2, e)

def find_hit_inside(+text: String, +p: Nat, +j: Nat, +target: Char, +right: Bool,
  h: {NavigationFind.hit(text,p,j,target,right) == True{} : Bool}) ->
  {NavigationModel.inside(j) == True{} : Bool}:
  and_left(NavigationModel.inside(j),
    Bool.and(Nat.is_eq(NavigationModel.row(j), NavigationModel.row(p)),
      Bool.and(NavigationFind.toward(p,j,right),
        Char.is_eq(NavigationModel.text_at(text,j), target))), h)

def find_selected_from(+text: String, +p: Nat, +target: Char, +right: Bool, +count: Nat,
  hle: {Nat.is_le(count, NavigationFind.total(text,p,target,right)) == True{} : Bool},
  w: ScanComplete(40n,text,p,target,right,
    NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
    NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))) ->
  {NavigationFind.selected(text,p,target,right,count,
    NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
      NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
      NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)))) == True{} : Bool}:
  match w:
    case (+j, (scan_eq, (hit_eq, (hits_eq, (below_eq, match_eq))))):
      +hitp = hit_eq
      +eq_hits = eq_is_eq(NavigationFind.hits(40n,text,p,j,target,right),
        NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)), hits_eq)
      +out_eq = Equal.trans(Nat,
        NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
          NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
          NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))),
        NavigationFindImpl.pick(p, NavigationFindImpl.Found{j}),
        j,
        find_pick_congr(p, NavigationFindImpl.scan(40n,text,p,target,right,
          NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
          NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)),
          NavigationFindImpl.Found{j}, scan_eq),
        find_pick_found(p,j))
      Equal.trans(Bool,
        NavigationFind.selected(text,p,target,right,count,
          NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
            NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
            NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)))),
        NavigationFind.selected(text,p,target,right,count,j),
        True{},
        Equal.cong(Nat, Bool, (z => NavigationFind.selected(text,p,target,right,count,z)),
          NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
            NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
            NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))),
          j, out_eq),
        or_true_of_true_l(
          Bool.and(Nat.is_le(count, NavigationFind.total(text,p,target,right)),
            Bool.and(NavigationFind.hit(text,p,j,target,right),
              Nat.is_eq(NavigationFind.hits(40n,text,p,j,target,right),
                NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right))))),
          Bool.and(Nat.is_gt(count, NavigationFind.total(text,p,target,right)),
            Nat.is_eq(j,p)),
          and_intro(Nat.is_le(count, NavigationFind.total(text,p,target,right)),
            Bool.and(NavigationFind.hit(text,p,j,target,right),
              Nat.is_eq(NavigationFind.hits(40n,text,p,j,target,right),
                NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)))),
            hle,
            and_intro(NavigationFind.hit(text,p,j,target,right),
              Nat.is_eq(NavigationFind.hits(40n,text,p,j,target,right),
                NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right))),
              hitp, eq_hits))))

def find_move_plus(+f: NavigationModel.Field, +p: Nat, +target: Char, +right: Bool,
  +k: Nat, g: Bool,
  hg: {g == Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)) : Bool}) ->
  {NavigationFindImpl.move_impl(f,p,target,right,1n+k) ==
    NavigationFindImpl.move_positive(f,p,target,right,1n+k,g) : Nat}:
  Equal.cong(Bool, Nat,
    (z => NavigationFindImpl.move_positive(f,p,target,right,1n+k,z)),
    Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
    g, Equal.sym(Bool, g,
      Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)), hg))

law find_contents_norm:
  for f: NavigationModel.Field
  {NavigationModel.contents(f) == NavigationModelImpl.norm(800n,f) : String}

def find_contents_norm(f):
  {==}

def find_exact_plus(+f: NavigationModel.Field, +p: Nat, +target: Char, +right: Bool,
  +k: Nat, +ok: {NavigationModel.inside(p) == True{} : Bool}, g: Bool,
  hg: {g == Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)) : Bool}) ->
  {NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
    NavigationFindImpl.move_impl(f,p,target,right,1n+k)) == True{} : Bool}:
  match g:
    case True{}:
      +hgc = hg
      +hle = Equal.sym(Bool, g,
        Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)), hgc)
      +hcount = one_le_one_add(k)
      +hr = rank_positive(right, 1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right), hcount)
      +hrankle = rank_le_total(right, 1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right), hcount, hle)
      +branch = find_selected_from(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,hle,
        scan_complete(40n,NavigationModelImpl.norm(800n,f),p,target,right,
          NavigationFind.rank(right,1n+k,NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
          NavigationFind.hit(NavigationModelImpl.norm(800n,f),p,NavigationModel.index(NavigationModel.row(p),39n),target,right),
          {==}, hr, hrankle))
      Equal.trans(Bool,
        NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
          NavigationFindImpl.move_impl(f,p,target,right,1n+k)),
        NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,True{})),
        True{},
        Equal.cong(Nat, Bool,
          (z => NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,z)),
          NavigationFindImpl.move_impl(f,p,target,right,1n+k),
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,True{}),
          find_move_plus(f,p,target,right,k,True{},hgc)),
        branch)
    case False{}:
      +hgc = hg
      +notle = Equal.sym(Bool, g,
        Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)), hgc)
      +hgt = gt_of_not_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right), notle)
      +branch = or_true_of_true_r(
        Bool.and(Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
          Bool.and(NavigationFind.hit(NavigationModelImpl.norm(800n,f),p,p,target,right),
            Nat.is_eq(NavigationFind.hits(40n,NavigationModelImpl.norm(800n,f),p,p,target,right),
              NavigationFind.rank(right,1n+k,NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right))))),
        Bool.and(Nat.is_gt(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
          Nat.is_eq(p,p)),
        and_intro(Nat.is_gt(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
          Nat.is_eq(p,p), hgt, is_eq_refl(p)))
      Equal.trans(Bool,
        NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
          NavigationFindImpl.move_impl(f,p,target,right,1n+k)),
        NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,False{})),
        True{},
        Equal.cong(Nat, Bool,
          (z => NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,z)),
          NavigationFindImpl.move_impl(f,p,target,right,1n+k),
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,False{}),
          find_move_plus(f,p,target,right,k,False{},hgc)),
        branch)

def NavigationFind.exact(f,p,target,right,n,ok):
  Equal.trans(Bool,
    NavigationFind.selected(NavigationModelImpl.norm(800n,f),p,target,right,1n+n,
      NavigationFindImpl.move_impl(f,p,target,right,1n+n)),
    NavigationFind.selected(NavigationModel.contents(f),p,target,right,1n+n,
      NavigationFindImpl.move_impl(f,p,target,right,1n+n)),
    True{},
    Equal.cong(String, Bool,
      (z => NavigationFind.selected(z,p,target,right,1n+n,
        NavigationFindImpl.move_impl(f,p,target,right,1n+n))),
      NavigationModelImpl.norm(800n,f), NavigationModel.contents(f),
      Equal.sym(String, NavigationModel.contents(f), NavigationModelImpl.norm(800n,f),
        find_contents_norm(f))),
    find_exact_plus(f,p,target,right,n,ok,
      Nat.is_le(1n+n, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
      {==}))

def find_bounded_from(+text: String, +p: Nat, +target: Char, +right: Bool, +count: Nat,
  w: ScanComplete(40n,text,p,target,right,
    NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
    NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))) ->
  {NavigationModel.inside(NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
    NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
    NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)))) == True{} : Bool}:
  match w:
    case (+j, (scan_eq, (hit_eq, (hits_eq, (below_eq, match_eq))))):
      +hitp = hit_eq
      +out_eq = Equal.trans(Nat,
        NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
          NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
          NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))),
        NavigationFindImpl.pick(p, NavigationFindImpl.Found{j}),
        j,
        find_pick_congr(p, NavigationFindImpl.scan(40n,text,p,target,right,
          NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
          NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)),
          NavigationFindImpl.Found{j}, scan_eq),
        find_pick_found(p,j))
      Equal.trans(Bool,
        NavigationModel.inside(NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
          NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
          NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right)))),
        NavigationModel.inside(j),
        True{},
        Equal.cong(Nat, Bool, (z => NavigationModel.inside(z)),
          NavigationFindImpl.pick(p, NavigationFindImpl.scan(40n,text,p,target,right,
            NavigationFind.rank(right,count,NavigationFind.total(text,p,target,right)),
            NavigationFind.hit(text,p,NavigationModel.index(NavigationModel.row(p),39n),target,right))),
          j, out_eq),
        find_hit_inside(text,p,j,target,right,hitp))

def find_bounded_plus(+f: NavigationModel.Field, +p: Nat, +target: Char, +right: Bool,
  +k: Nat, +ok: {NavigationModel.inside(p) == True{} : Bool}, g: Bool,
  hg: {g == Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)) : Bool}) ->
  {NavigationModel.inside(NavigationFindImpl.move_impl(f,p,target,right,1n+k)) == True{} : Bool}:
  match g:
    case True{}:
      +hgc = hg
      +hle = Equal.sym(Bool, g,
        Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)), hgc)
      +hcount = one_le_one_add(k)
      +hr = rank_positive(right, 1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right), hcount)
      +hrankle = rank_le_total(right, 1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right), hcount, hle)
      +branch = find_bounded_from(NavigationModelImpl.norm(800n,f),p,target,right,1n+k,
        scan_complete(40n,NavigationModelImpl.norm(800n,f),p,target,right,
          NavigationFind.rank(right,1n+k,NavigationFind.total(NavigationModelImpl.norm(800n,f),p,target,right)),
          NavigationFind.hit(NavigationModelImpl.norm(800n,f),p,NavigationModel.index(NavigationModel.row(p),39n),target,right),
          {==}, hr, hrankle))
      Equal.trans(Bool,
        NavigationModel.inside(NavigationFindImpl.move_impl(f,p,target,right,1n+k)),
        NavigationModel.inside(NavigationFindImpl.move_positive(f,p,target,right,1n+k,True{})),
        True{},
        Equal.cong(Nat, Bool, (z => NavigationModel.inside(z)),
          NavigationFindImpl.move_impl(f,p,target,right,1n+k),
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,True{}),
          find_move_plus(f,p,target,right,k,True{},hgc)),
        branch)
    case False{}:
      +hgc = hg
      Equal.trans(Bool,
        NavigationModel.inside(NavigationFindImpl.move_impl(f,p,target,right,1n+k)),
        NavigationModel.inside(NavigationFindImpl.move_positive(f,p,target,right,1n+k,False{})),
        True{},
        Equal.cong(Nat, Bool, (z => NavigationModel.inside(z)),
          NavigationFindImpl.move_impl(f,p,target,right,1n+k),
          NavigationFindImpl.move_positive(f,p,target,right,1n+k,False{}),
          find_move_plus(f,p,target,right,k,False{},hgc)),
        ok)

def NavigationFind.bounded(f,p,target,right,n,ok):
  match n:
    case 0n:
      ok
    case 1n++k:
      +ff = f
      +pp = p
      +tt = target
      +rr = right
      find_bounded_plus(ff,pp,tt,rr,k,ok,
        Nat.is_le(1n+k, NavigationFind.total(NavigationModelImpl.norm(800n,ff),pp,tt,rr)), {==})



def or_true_l(a: Bool, +b: Bool, h: {a == True{} : Bool}) ->
  {Bool.or(a, b) == True{} : Bool}:
  match a:
    case True{}:
      {==}
    case False{}:
      empty_elim({b == True{} : Bool}, absurd_eq(h))

def normal_known_true(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, h: {flag == True{} : Bool}) ->
  {NavigationInputImpl.normal_known(f, p, n, c, flag) ==
    NavigationInputImpl.normal_supported(f, p, n, c) : NavigationModel.View}:
  match flag:
    case True{}:
      {==}
    case False{}:
      empty_elim({NavigationInputImpl.normal_known(f, p, n, c, False{}) ==
        NavigationInputImpl.normal_supported(f, p, n, c) : NavigationModel.View},
        absurd_eq(h))

def normal_nonzero_true(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, h: {flag == True{} : Bool}) ->
  {NavigationInputImpl.normal_nonzero_digit(f, p, n, c, flag) ==
    NavigationModel.View{f, p,
      NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}} :
    NavigationModel.View}:
  match flag:
    case True{}:
      {==}
    case False{}:
      empty_elim({NavigationInputImpl.normal_nonzero_digit(f, p, n, c, False{}) ==
        NavigationModel.View{f, p,
          NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}} :
        NavigationModel.View},
        absurd_eq(h))

# --- Navigation input implementation proofs ---

def active_if_true(state: NavigationModel.State, +c: Char, flag: Bool,
  h: {flag == True{} : Bool}) ->
  {NavigationInputImpl.character_active_if(state, c, flag) ==
    NavigationInputImpl.character_printable(state, c) : NavigationModel.View}:
  match flag:
    case True{}:
      {==}
    case False{}:
      empty_elim({NavigationInputImpl.character_active_if(state, c, False{}) ==
        NavigationInputImpl.character_printable(state, c) : NavigationModel.View},
        absurd_eq(h))

def active_if_false(state: NavigationModel.State, +c: Char, flag: Bool,
  h: {flag == False{} : Bool}) ->
  {NavigationInputImpl.character_active_if(state, c, flag) ==
    state : NavigationModel.View}:
  match flag:
    case False{}:
      {==}
    case True{}:
      empty_elim({NavigationInputImpl.character_active_if(state, c, True{}) ==
        state : NavigationModel.View},
        absurd_eq(Equal.sym(Bool, True{}, False{}, h)))

def step_char_true(state: NavigationModel.State, +c: Char,
  h: {NavigationModel.printable(c) == True{} : Bool}) ->
  {NavigationInput.step(state, NavigationModel.Character{c, False{}}) ==
    NavigationInputImpl.character_printable(state, c) : NavigationModel.View}:
  active_if_true(state, c, NavigationModel.printable(c), h)

def normal_known_false(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, h: {flag == False{} : Bool}) ->
  {NavigationInputImpl.normal_known(f, p, n, c, flag) ==
    NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View}:
  match flag:
    case False{}:
      {==}
    case True{}:
      empty_elim({NavigationInputImpl.normal_known(f, p, n, c, True{}) ==
        NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View},
        absurd_eq(Equal.sym(Bool, True{}, False{}, h)))

def go_if_false(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, h: {flag == False{} : Bool}) ->
  {NavigationInputImpl.go_input_if(f, p, n, c, flag) ==
    NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View}:
  match flag:
    case False{}:
      {==}
    case True{}:
      empty_elim({NavigationInputImpl.go_input_if(f, p, n, c, True{}) ==
        NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View},
        absurd_eq(Equal.sym(Bool, True{}, False{}, h)))

def NavigationInput.respects_view(s, key):
  {==}

def NavigationInput.other(s):
  {==}

def NavigationInput.blocked_character(s, c):
  {==}

def NavigationInput.blocked_escape(s):
  {==}

def NavigationInput.escape(f, p, m, pos, mode):
  {==}

def NavigationInput.nonprintable(s, c, no):
  active_if_false(s, c, NavigationModel.printable(c), no)

def NavigationInput.axis(f, p, n, d, pos, count):
  match d:
    case NavigationAxis.Left{}:
      {==}
    case NavigationAxis.Down{}:
      {==}
    case NavigationAxis.Up{}:
      {==}
    case NavigationAxis.Right{}:
      {==}

def NavigationInput.words(f, p, n, m, big, pos, count):
  match m big:
    case NavigationWords.Forward{} False{}:
      {==}
    case NavigationWords.Forward{} True{}:
      {==}
    case NavigationWords.Backward{} False{}:
      {==}
    case NavigationWords.Backward{} True{}:
      {==}
    case NavigationWords.End{} False{}:
      {==}
    case NavigationWords.End{} True{}:
      {==}

def NavigationInput.zero_column(f, p, pos):
  {==}

def NavigationInput.first_nonblank(f, p, n, pos, count):
  {==}

def NavigationInput.row_end(f, p, n, pos, count):
  {==}

def NavigationInput.last_row(f, p, n, pos, count):
  {==}

def NavigationInput.find_right_prefix(f, p, n, pos, count):
  {==}

def NavigationInput.find_left_prefix(f, p, n, pos, count):
  {==}

def NavigationInput.find_target(f, p, n, right, c, pos, count, char):
  match right:
    case True{}:
      step_char_true(NavigationModel.View{f, p, NavigationModel.FindRight{n}}, c, char)
    case False{}:
      step_char_true(NavigationModel.View{f, p, NavigationModel.FindLeft{n}}, c, char)

def NavigationInput.go_prefix(f, p, n, pos, count):
  {==}

def NavigationInput.go_complete(f, p, n, pos, count):
  {==}

def NavigationInput.go_invalid(f, p, n, c, pos, count, char, not_g):
  %Equal.sym(NavigationModel.View,
    NavigationInput.step(NavigationModel.pack(NavigationModel.View{f, p, NavigationModel.Go{n}}),
      NavigationModel.Character{c, False{}}),
    NavigationInputImpl.character_printable(
      NavigationModel.View{f, p, NavigationModel.Go{n}}, c),
    step_char_true(NavigationModel.View{f, p, NavigationModel.Go{n}}, c, char)) :
    {_ == NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View}
  go_if_false(f, p, n, c, Char.is_eq(c, 'g'), not_g)

def NavigationInput.nonzero_digit(f, p, n, c, pos, count, char):
  +char_ok = char
  +digit = and_left(Char.is_digit(c), Bool.not(Char.is_eq(c, '0')), char_ok)
  not_zero = and_right(Char.is_digit(c), Bool.not(Char.is_eq(c, '0')), char_ok)
  +printable_ok = or_true_l(Char.is_digit(c),
    Bool.and(U32.is_ge(Char.to_u32(c), 32), U32.is_le(Char.to_u32(c), 126)),
    digit)
  +recognized_ok = or_true_l(Char.is_digit(c),
    NavigationInput.contains("hjklwbeWBE^$fFgG", c), digit)
  +nonzero_ok = and_intro(Char.is_digit(c), Bool.not(Char.is_eq(c, '0')),
    digit, not_zero)
  %Equal.sym(NavigationModel.View,
    NavigationInput.step(NavigationModel.pack(
      NavigationModel.View{f, p, NavigationModel.Normal{n}}),
      NavigationModel.Character{c, False{}}),
    NavigationInputImpl.character_printable(
      NavigationModel.View{f, p, NavigationModel.Normal{n}}, c),
    step_char_true(NavigationModel.View{f, p, NavigationModel.Normal{n}}, c,
      printable_ok)) :
    {_ == NavigationModel.View{f, p,
      NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}} :
      NavigationModel.View}
  %Equal.sym(NavigationModel.View,
    NavigationInputImpl.normal_known(f, p, n, c, NavigationInput.recognized(c)),
    NavigationInputImpl.normal_supported(f, p, n, c),
    normal_known_true(f, p, n, c, NavigationInput.recognized(c), recognized_ok)) :
    {_ == NavigationModel.View{f, p,
      NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}} :
      NavigationModel.View}
  %Equal.sym(NavigationModel.View,
    NavigationInputImpl.normal_nonzero_digit(f, p, n, c,
      Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0')))),
    NavigationModel.View{f, p,
      NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}},
    normal_nonzero_true(f, p, n, c,
      Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0'))), nonzero_ok)) :
    {_ == NavigationModel.View{f, p,
      NavigationModel.Normal{NavigationInput.append_count(n, NavigationInput.digit(c))}} :
      NavigationModel.View}
  {==}

def NavigationInput.zero_digit(f, p, n, pos, count):
  match n:
    case 0n:
      empty_elim({NavigationModel.view(NavigationInput.step(
        NavigationModel.pack(NavigationModel.View{f, p, NavigationModel.Normal{0n}}),
        NavigationModel.Character{'0', False{}})) ==
        NavigationModel.View{f, p,
          NavigationModel.Normal{NavigationInput.append_count(0n, 0n)}} : NavigationModel.View},
        absurd_eq(count))
    case 1n+k:
      {==}

def NavigationInput.unsupported(f, p, n, c, pos, count, char, unknown):
  %Equal.sym(NavigationModel.View,
    NavigationInput.step(NavigationModel.pack(
      NavigationModel.View{f, p, NavigationModel.Normal{n}}),
      NavigationModel.Character{c, False{}}),
    NavigationInputImpl.character_printable(
      NavigationModel.View{f, p, NavigationModel.Normal{n}}, c),
    step_char_true(NavigationModel.View{f, p, NavigationModel.Normal{n}}, c, char)) :
    {_ == NavigationModel.View{f, p, NavigationModel.Normal{0n}} : NavigationModel.View}
  normal_known_false(f, p, n, c, NavigationInput.recognized(c), unknown)

def board_normal_big_f(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_big_f(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      {==}

def board_normal_f(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_f(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_big_f(f, p, n, c, Char.is_eq(c, 'F'))

def board_normal_g(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_g(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_f(f, p, n, c, Char.is_eq(c, 'f'))

def board_normal_big_g(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_big_g(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_g(f, p, n, c, Char.is_eq(c, 'g'))

def board_normal_dollar(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_dollar(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_big_g(f, p, n, c, Char.is_eq(c, 'G'))

def board_normal_caret(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_caret(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_dollar(f, p, n, c, Char.is_eq(c, '$'))

def board_normal_big_e(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_big_e(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_caret(f, p, n, c, Char.is_eq(c, '^'))

def board_normal_e(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_e(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_big_e(f, p, n, c, Char.is_eq(c, 'E'))

def board_normal_big_b(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_big_b(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_e(f, p, n, c, Char.is_eq(c, 'e'))

def board_normal_b(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_b(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_big_b(f, p, n, c, Char.is_eq(c, 'B'))

def board_normal_big_w(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_big_w(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_b(f, p, n, c, Char.is_eq(c, 'b'))

def board_normal_w(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_w(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_big_w(f, p, n, c, Char.is_eq(c, 'W'))

def board_normal_l(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_l(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_w(f, p, n, c, Char.is_eq(c, 'w'))

def board_normal_k(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_k(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_l(f, p, n, c, Char.is_eq(c, 'l'))

def board_normal_j(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_j(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_k(f, p, n, c, Char.is_eq(c, 'k'))

def board_normal_h(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_h(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_j(f, p, n, c, Char.is_eq(c, 'j'))

def board_normal_zero(+f: NavigationModel.Field, +p: Nat, +n: Nat) ->
  {NavigationModel.board(NavigationInputImpl.normal_zero(f, p, n)) ==
    f : NavigationModel.Field}:
  match n:
    case 0n:
      {==}
    case 1n+k:
      {==}

def board_normal_zero_digit(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_zero_digit(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      board_normal_zero(f, p, n)
    case False{}:
      board_normal_h(f, p, n, c, Char.is_eq(c, 'h'))

def board_normal_nonzero_digit(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  +c: Char, flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_nonzero_digit(f, p, n, c, flag)) ==
    f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      board_normal_zero_digit(f, p, n, c, Char.is_eq(c, '0'))

def board_normal_supported(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  +c: Char) -> {NavigationModel.board(
    NavigationInputImpl.normal_supported(f, p, n, c)) == f : NavigationModel.Field}:
  board_normal_nonzero_digit(f, p, n, c,
    Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0'))))

def board_normal_known(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.normal_known(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      board_normal_supported(f, p, n, c)
    case False{}:
      {==}

def board_normal_input(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char) ->
  {NavigationModel.board(NavigationInputImpl.normal_input(f, p, n, c)) ==
    f : NavigationModel.Field}:
  board_normal_known(f, p, n, c, NavigationInput.recognized(c))

def board_go_input_if(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool) -> {NavigationModel.board(
    NavigationInputImpl.go_input_if(f, p, n, c, flag)) == f : NavigationModel.Field}:
  match flag:
    case True{}:
      {==}
    case False{}:
      {==}

def board_go_input(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char) ->
  {NavigationModel.board(NavigationInputImpl.go_input(f, p, n, c)) ==
    f : NavigationModel.Field}:
  board_go_input_if(f, p, n, c, Char.is_eq(c, 'g'))

def board_character_printable(state: NavigationModel.State, +c: Char) ->
  {NavigationModel.board(NavigationInputImpl.character_printable(state, c)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match state:
    case NavigationModel.View{f, p, m}:
      match m:
        case NavigationModel.Normal{n}:
          board_normal_input(f, p, n, c)
        case NavigationModel.FindRight{n}:
          {==}
        case NavigationModel.FindLeft{n}:
          {==}
        case NavigationModel.Go{n}:
          board_go_input(f, p, n, c)

def board_character_active_if(state: NavigationModel.State, +c: Char, flag: Bool) ->
  {NavigationModel.board(NavigationInputImpl.character_active_if(state, c, flag)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match flag:
    case True{}:
      board_character_printable(state, c)
    case False{}:
      {==}

def board_character_active(state: NavigationModel.State, +c: Char) ->
  {NavigationModel.board(NavigationInputImpl.character_active(state, c)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  board_character_active_if(state, c, NavigationModel.printable(c))

def board_character_input(state: NavigationModel.State, +c: Char, blocked: Bool) ->
  {NavigationModel.board(NavigationInputImpl.character_input(state, c, blocked)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match blocked:
    case True{}:
      {==}
    case False{}:
      board_character_active(state, c)

def board_clear_state(state: NavigationModel.State) ->
  {NavigationModel.board(NavigationInputImpl.clear_state(state)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match state:
    case NavigationModel.View{f, p, m}:
      {==}

def board_escape_input(state: NavigationModel.State, blocked: Bool) ->
  {NavigationModel.board(NavigationInputImpl.escape_input(state, blocked)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match blocked:
    case True{}:
      {==}
    case False{}:
      board_clear_state(state)

def step_board(state: NavigationModel.State, input: NavigationModel.Input) ->
  {NavigationModel.board(NavigationInput.step(state, input)) ==
    NavigationModel.board(state) : NavigationModel.Field}:
  match input:
    case NavigationModel.Other{}:
      {==}
    case NavigationModel.Escape{blocked}:
      board_escape_input(state, blocked)
    case NavigationModel.Character{value, blocked}:
      board_character_input(state, value, blocked)

def NavigationInput.preserves_field(s, key, ok):
  step_board(s, key)

law min_le_left_nat:
  for +a: Nat
  for +b: Nat
  {Nat.is_le(Nat.min(a, b), a) == True{} : Bool}

def min_le_left_nat(a, b):
  match a b:
    case 0n _:
      {==}
    case 1n+p 0n:
      {==}
    case 1n+p 1n+q:
      min_le_left_nat(p, q)

law effective_positive:
  for +n: Nat
  {Nat.is_gt(Nat.max(1n, n), 0n) == True{} : Bool}

def effective_positive(n):
  match n:
    case 0n:
      {==}
    case 1n+k:
      {==}

law effective_le_9999:
  for +n: Nat
  for h: {Nat.is_le(n, 9999n) == True{} : Bool}
  {Nat.is_le(Nat.max(1n, n), 9999n) == True{} : Bool}

def effective_le_9999(n, h):
  match n:
    case 0n:
      {==}
    case 1n+k:
      h

def valid_normal_zero_at(+f: NavigationModel.Field, +out: Nat,
  hin: {NavigationModel.inside(out) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationModel.View{f, out, NavigationModel.Normal{0n}}) ==
    True{} : Bool}:
  and_intro(NavigationModel.inside(out), Nat.is_le(0n, 9999n), hin, {==})

def valid_normal_append_at(+f: NavigationModel.Field, +p: Nat, +n: Nat, +d: Nat,
  hin: {NavigationModel.inside(p) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationModel.View{f, p,
    NavigationModel.Normal{NavigationInput.append_count(n, d)}}) == True{} : Bool}:
  and_intro(NavigationModel.inside(p),
    Nat.is_le(Nat.min(9999n, Nat.add(Nat.mul(n, 10n), d)), 9999n),
    hin, min_le_left_nat(9999n, Nat.add(Nat.mul(n, 10n), d)))

def valid_find_prefix_at(+f: NavigationModel.Field, +p: Nat, +n: Nat, right: Bool,
  hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationModel.View{f, p,
    NavigationInput.find_mode(right, NavigationModel.effective(n))}) ==
    True{} : Bool}:
  match right:
    case True{}:
      and_intro(NavigationModel.inside(p),
        Bool.and(Nat.is_gt(NavigationModel.effective(n), 0n),
          Nat.is_le(NavigationModel.effective(n), 9999n)),
        hin,
        and_intro(Nat.is_gt(NavigationModel.effective(n), 0n),
          Nat.is_le(NavigationModel.effective(n), 9999n),
          effective_positive(n), effective_le_9999(n, hcount)))
    case False{}:
      and_intro(NavigationModel.inside(p),
        Bool.and(Nat.is_gt(NavigationModel.effective(n), 0n),
          Nat.is_le(NavigationModel.effective(n), 9999n)),
        hin,
        and_intro(Nat.is_gt(NavigationModel.effective(n), 0n),
          Nat.is_le(NavigationModel.effective(n), 9999n),
          effective_positive(n), effective_le_9999(n, hcount)))

def valid_go_prefix_at(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationModel.View{f, p, NavigationModel.Go{n}}) ==
    True{} : Bool}:
  and_intro(NavigationModel.inside(p), Nat.is_le(n, 9999n), hin, hcount)

def normal_big_f_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.normal_big_f(f, p, n, c, flag)) == True{} : Bool}:
  match flag:
    case True{}:
      valid_find_prefix_at(f, p, n, False{}, hin, hcount)
    case False{}:
      valid_normal_zero_at(f, p, hin)

def normal_f_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_f(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_find_prefix_at(f, p, n, True{}, hin, hcount)
    case False{}:
      normal_big_f_valid(f, p, n, c, Char.is_eq(c, 'F'), hin, hcount)

def normal_g_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_g(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      and_intro(NavigationModel.inside(p), Nat.is_le(n, 9999n), hin, hcount)
    case False{}:
      normal_f_valid(f, p, n, c, Char.is_eq(c, 'f'), hin, hcount)

def normal_big_g_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_big_g(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationLines.move(f, p, NavigationLines.LastRow{}, n),
        NavigationLines.bounded(f, p, NavigationLines.LastRow{}, n, hin))
    case False{}:
      normal_g_valid(f, p, n, c, Char.is_eq(c, 'g'), hin, hcount)

def normal_dollar_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_dollar(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationLines.move(f, p, NavigationLines.RowEnd{}, n),
        NavigationLines.bounded(f, p, NavigationLines.RowEnd{}, n, hin))
    case False{}:
      normal_big_g_valid(f, p, n, c, Char.is_eq(c, 'G'), hin, hcount)

def normal_caret_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_caret(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationLines.move(f, p, NavigationLines.FirstNonblank{}, n),
        NavigationLines.bounded(f, p, NavigationLines.FirstNonblank{}, n, hin))
    case False{}:
      normal_dollar_valid(f, p, n, c, Char.is_eq(c, '$'), hin, hcount)

def normal_big_e_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_big_e(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.End{}, True{}),
        NavigationWords.bounded(f, p, NavigationWords.End{}, True{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_caret_valid(f, p, n, c, Char.is_eq(c, '^'), hin, hcount)

def normal_e_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_e(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.End{}, False{}),
        NavigationWords.bounded(f, p, NavigationWords.End{}, False{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_big_e_valid(f, p, n, c, Char.is_eq(c, 'E'), hin, hcount)

def normal_big_b_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_big_b(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.Backward{}, True{}),
        NavigationWords.bounded(f, p, NavigationWords.Backward{}, True{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_e_valid(f, p, n, c, Char.is_eq(c, 'e'), hin, hcount)

def normal_b_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_b(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.Backward{}, False{}),
        NavigationWords.bounded(f, p, NavigationWords.Backward{}, False{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_big_b_valid(f, p, n, c, Char.is_eq(c, 'B'), hin, hcount)

def normal_big_w_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_big_w(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.Forward{}, True{}),
        NavigationWords.bounded(f, p, NavigationWords.Forward{}, True{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_b_valid(f, p, n, c, Char.is_eq(c, 'b'), hin, hcount)

def normal_w_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_w(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationWordsImpl.move_impl(NavigationModel.effective(n), f, p,
          NavigationWords.Forward{}, False{}),
        NavigationWords.bounded(f, p, NavigationWords.Forward{}, False{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_big_w_valid(f, p, n, c, Char.is_eq(c, 'W'), hin, hcount)

def normal_l_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_l(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationAxis.move(p, NavigationAxis.Right{}, NavigationModel.effective(n)),
        NavigationAxis.bounded(p, NavigationAxis.Right{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_w_valid(f, p, n, c, Char.is_eq(c, 'w'), hin, hcount)

def normal_k_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_k(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationAxis.move(p, NavigationAxis.Up{}, NavigationModel.effective(n)),
        NavigationAxis.bounded(p, NavigationAxis.Up{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_l_valid(f, p, n, c, Char.is_eq(c, 'l'), hin, hcount)

def normal_j_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_j(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationAxis.move(p, NavigationAxis.Down{}, NavigationModel.effective(n)),
        NavigationAxis.bounded(p, NavigationAxis.Down{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_k_valid(f, p, n, c, Char.is_eq(c, 'k'), hin, hcount)

def normal_h_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_h(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationAxis.move(p, NavigationAxis.Left{}, NavigationModel.effective(n)),
        NavigationAxis.bounded(p, NavigationAxis.Left{},
          NavigationModel.effective(n), hin))
    case False{}:
      normal_j_valid(f, p, n, c, Char.is_eq(c, 'j'), hin, hcount)

def normal_zero_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_zero(f, p, n)) ==
    True{} : Bool}:
  match n:
    case 0n:
      valid_normal_zero_at(f,
        NavigationLines.move(f, p, NavigationLines.ColumnZero{}, 0n),
        NavigationLines.bounded(f, p, NavigationLines.ColumnZero{}, 0n, hin))
    case 1n+k:
      valid_normal_append_at(f, p, 1n+k, 0n, hin)

def normal_zero_digit_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  +c: Char, flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.normal_zero_digit(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      normal_zero_valid(f, p, n, hin, hcount)
    case False{}:
      normal_h_valid(f, p, n, c, Char.is_eq(c, 'h'), hin, hcount)

def normal_nonzero_digit_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat,
  +c: Char, flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.normal_nonzero_digit(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_append_at(f, p, n, NavigationInput.digit(c), hin)
    case False{}:
      normal_zero_digit_valid(f, p, n, c, Char.is_eq(c, '0'), hin, hcount)

def normal_supported_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_supported(f, p, n, c)) ==
    True{} : Bool}:
  normal_nonzero_digit_valid(f, p, n, c,
    Bool.and(Char.is_digit(c), Bool.not(Char.is_eq(c, '0'))), hin, hcount)

def normal_known_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool},
  hcount: {Nat.is_le(n, 9999n) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.normal_known(f, p, n, c, flag)) == True{} : Bool}:
  match flag:
    case True{}:
      normal_supported_valid(f, p, n, c, hin, hcount)
    case False{}:
      valid_normal_zero_at(f, p, hin)

def normal_input_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  ok: {NavigationModel.valid(
    NavigationModel.View{f, p, NavigationModel.Normal{n}}) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.normal_input(f, p, n, c)) ==
    True{} : Bool}:
  +ok0 = ok
  +hin = and_left(NavigationModel.inside(p),
    NavigationModel.mode_valid(NavigationModel.Normal{n}), ok0)
  +hcount = and_right(NavigationModel.inside(p),
    NavigationModel.mode_valid(NavigationModel.Normal{n}), ok0)
  normal_known_valid(f, p, n, c, NavigationInput.recognized(c), hin, hcount)

def go_input_if_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  flag: Bool, hin: {NavigationModel.inside(p) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.go_input_if(f, p, n, c, flag)) ==
    True{} : Bool}:
  match flag:
    case True{}:
      valid_normal_zero_at(f,
        NavigationLines.move(f, p, NavigationLines.FirstRow{}, n),
        NavigationLines.bounded(f, p, NavigationLines.FirstRow{}, n, hin))
    case False{}:
      valid_normal_zero_at(f, p, hin)

def go_input_valid(+f: NavigationModel.Field, +p: Nat, +n: Nat, +c: Char,
  hin: {NavigationModel.inside(p) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.go_input(f, p, n, c)) ==
    True{} : Bool}:
  go_input_if_valid(f, p, n, c, Char.is_eq(c, 'g'), hin)

def character_printable_valid(+state: NavigationModel.State, +c: Char,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.character_printable(state, c)) == True{} : Bool}:
  match state:
    case NavigationModel.View{+f, +p, m}:
      match m:
        case NavigationModel.Normal{n}:
          normal_input_valid(f, p, n, c, ok)
        case NavigationModel.FindRight{n}:
          +ok0 = ok
          +hin = and_left(NavigationModel.inside(p),
            NavigationModel.mode_valid(NavigationModel.FindRight{n}), ok0)
          valid_normal_zero_at(f,
            NavigationFind.move(f, p, c, True{}, n),
            NavigationFind.bounded(f, p, c, True{}, n, hin))
        case NavigationModel.FindLeft{n}:
          +ok0 = ok
          +hin = and_left(NavigationModel.inside(p),
            NavigationModel.mode_valid(NavigationModel.FindLeft{n}), ok0)
          valid_normal_zero_at(f,
            NavigationFind.move(f, p, c, False{}, n),
            NavigationFind.bounded(f, p, c, False{}, n, hin))
        case NavigationModel.Go{n}:
          +ok0 = ok
          +hin = and_left(NavigationModel.inside(p),
            NavigationModel.mode_valid(NavigationModel.Go{n}), ok0)
          go_input_valid(f, p, n, c, hin)

def character_active_if_valid(+state: NavigationModel.State, +c: Char, flag: Bool,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.character_active_if(state, c, flag)) == True{} : Bool}:
  match flag:
    case True{}:
      character_printable_valid(state, c, ok)
    case False{}:
      ok

def character_active_valid(+state: NavigationModel.State, +c: Char,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.character_active(state, c)) == True{} : Bool}:
  character_active_if_valid(state, c, NavigationModel.printable(c), ok)

def character_input_valid(+state: NavigationModel.State, +c: Char, blocked: Bool,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(
    NavigationInputImpl.character_input(state, c, blocked)) == True{} : Bool}:
  match blocked:
    case True{}:
      ok
    case False{}:
      character_active_valid(state, c, ok)

def clear_valid(state: NavigationModel.State,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.clear_state(state)) == True{} : Bool}:
  match state:
    case NavigationModel.View{+f, +p, m}:
      +ok0 = ok
      +hin = and_left(NavigationModel.inside(p), NavigationModel.mode_valid(m), ok0)
      valid_normal_zero_at(f, p, hin)

def escape_input_valid(+state: NavigationModel.State, blocked: Bool,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInputImpl.escape_input(state, blocked)) ==
    True{} : Bool}:
  match blocked:
    case True{}:
      ok
    case False{}:
      clear_valid(state, ok)

def step_valid(+state: NavigationModel.State, input: NavigationModel.Input,
  +ok: {NavigationModel.valid(NavigationModel.view(state)) == True{} : Bool}) ->
  {NavigationModel.valid(NavigationInput.step(state, input)) == True{} : Bool}:
  match input:
    case NavigationModel.Other{}:
      ok
    case NavigationModel.Escape{blocked}:
      escape_input_valid(state, blocked, ok)
    case NavigationModel.Character{value, blocked}:
      character_input_valid(state, value, blocked, ok)

def NavigationInput.preserves_validity(s, key, ok):
  step_valid(s, key, ok)
