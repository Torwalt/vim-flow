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
import ./src/core/navigation_lines.bend as NavigationLinesImpl

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
