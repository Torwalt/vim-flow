import Base

law use_assumption:
  for +p: Nat
  for ok: {p == 0n : Nat}
  {p == 0n : Nat}

def use_assumption(p, ok):
  ok
