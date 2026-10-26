import Base
import ../../spec/navigation/model.bend as Model

def Model.Field(): String
def Model.State(): Model.View

def at_inside(f: String, p: Nat, ok: Bool) -> Char:
  match ok:
    case True{}:
      Model.text_at(f, p)
    case False{}:
      ' '

def at_helper(f: String, +p: Nat) -> Char:
  at_inside(f, p, Model.inside(p))

def Model.field(text): text

def Model.at(f, p):
  at_helper(f, p)

def norm(fuel: Nat, text: String) -> String:
  match fuel:
    case 0n:
      SNil{}
    case 1n+k:
      match text:
        case SNil{}:
          SCon{' ', norm(k, SNil{})}
        case SCon{+c, rest}:
          SCon{Model.sanitize(c, Model.printable(c)), norm(k, rest)}

def Model.contents(f):
  norm(800n, f)

def Model.view(state):
  state

def Model.pack(snapshot):
  snapshot

def Model.initial():
  Model.View{Model.field(Model.seed_text()), 0n, Model.Normal{0n}}
