import Base
import ../../spec/navigation/model.bend as Model
import ../../spec/navigation/words.bend as Words
import ./navigation_model.bend as ModelImpl

def scan_up(+f: String, +p: Nat, +motion: Words.Motion, +big: Bool,
  fuel: Nat, +q: Nat, c: Bool) -> Nat:
  match fuel:
    case 0n:
      799n
    case 1n+k:
      match c:
        case True{}:
          q
        case False{}:
          scan_up(f, p, motion, big, k, Nat.add(q, 1n),
            Words.candidate(f, p, motion, big, Nat.add(q, 1n)))

def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

def scan_down(+f: String, +p: Nat, +motion: Words.Motion, +big: Bool,
  fuel: Nat, c: Bool) -> Nat:
  match fuel:
    case 0n:
      0n
    case 1n++k:
      match c:
        case True{}:
          k
        case False{}:
          scan_down(f, p, motion, big, k,
            Words.candidate(f, p, motion, big, pred(k)))

def step(+field: Model.Field, +p: Nat, motion: Words.Motion, +big: Bool) -> Nat:
  match motion:
    case Words.Forward{}:
      scan_up(ModelImpl.norm(800n, field), p, Words.Forward{}, big, 800n, 0n,
        Words.candidate(ModelImpl.norm(800n, field), p, Words.Forward{}, big, 0n))
    case Words.Backward{}:
      scan_down(ModelImpl.norm(800n, field), p, Words.Backward{}, big, 800n,
        Words.candidate(ModelImpl.norm(800n, field), p, Words.Backward{}, big, 799n))
    case Words.End{}:
      scan_up(ModelImpl.norm(800n, field), p, Words.End{}, big, 800n, 0n,
        Words.candidate(ModelImpl.norm(800n, field), p, Words.End{}, big, 0n))

def move_impl(count: Nat, +field: Model.Field, +p: Nat, +motion: Words.Motion,
  +big: Bool) -> Nat:
  match count:
    case 0n:
      p
    case 1n+k:
      move_impl(k, field, step(field, p, motion, big), motion, big)
