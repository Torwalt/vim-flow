import Base
import ../../spec/navigation/find.bend as Find
import ../../spec/navigation/model.bend as Model
import ./navigation_model.bend as ModelImpl

type Search is Data:
  Found{position: Nat}
  Missing{}

def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

def scan(+fuel: Nat, +text: String, +p: Nat, +target: Char, +right: Bool,
  rank: Nat, c: Bool) -> Search:
  match fuel:
    case 0n:
      Missing{}
    case 1n+i:
      match rank:
        case 0n:
          Missing{}
        case 1n++q:
          match q:
            case 0n:
              match c:
                case True{}:
                  Found{Model.index(Model.row(p), i)}
                case False{}:
                  scan(i, text, p, target, right, 1n,
                    Find.hit(text, p, Model.index(Model.row(p), pred(i)), target, right))
            case 1n+q2:
              match c:
                case True{}:
                  scan(i, text, p, target, right, q,
                    Find.hit(text, p, Model.index(Model.row(p), pred(i)), target, right))
                case False{}:
                  scan(i, text, p, target, right, 1n+q,
                    Find.hit(text, p, Model.index(Model.row(p), pred(i)), target, right))

def pick(fallback: Nat, res: Search) -> Nat:
  match res:
    case Found{position}:
      position
    case Missing{}:
      fallback

def move_positive(+field: Model.Field, +p: Nat, +target: Char, +right: Bool,
  count: Nat, ok: Bool) -> Nat:
  match ok:
    case True{}:
      pick(p, scan(40n, ModelImpl.norm(800n, field), p, target, right,
        Find.rank(right, count, Find.total(ModelImpl.norm(800n, field), p, target, right)),
        Find.hit(ModelImpl.norm(800n, field), p, Model.index(Model.row(p), 39n), target, right)))
    case False{}:
      p

def move_impl(+field: Model.Field, +p: Nat, +target: Char, +right: Bool,
  count: Nat) -> Nat:
  match count:
    case 0n:
      p
    case 1n++k:
      move_positive(field, p, target, right, 1n+k,
        Nat.is_le(1n+k, Find.total(ModelImpl.norm(800n, field), p, target, right)))

def Find.move(f, p, target, right, count):
  move_impl(f, p, target, right, count)
