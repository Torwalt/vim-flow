import Base
import ./model.bend as M

type Direction is Data:
  Left{}
  Down{}
  Up{}
  Right{}

law move:
  for position: Nat
  for direction: Direction
  for count: Nat
  Nat

law left:
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(p, Left{}, n) == M.index(M.row(p), Nat.sub(M.column(p), n)) : Nat}

law right:
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(p, Right{}, n) == M.index(M.row(p), Nat.min(39n, Nat.add(M.column(p), n))) : Nat}

law up:
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(p, Up{}, n) == M.index(Nat.sub(M.row(p), n), M.column(p)) : Nat}

law down:
  for +p: Nat
  for +n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {move(p, Down{}, n) == M.index(Nat.min(19n, Nat.add(M.row(p), n)), M.column(p)) : Nat}

law bounded:
  for +p: Nat
  for d: Direction
  for n: Nat
  for ok: {M.inside(p) == True{} : Bool}
  {M.inside(move(p, d, n)) == True{} : Bool}
