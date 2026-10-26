import Base

def cell(+value: Bool, outside: Bool) -> Bool:
  match outside:
    case False{}:
      value
    case True{}:
      False{}

def When(b: Bool, P: Type) -> Type:
  match b:
    case False{}:
      Unit
    case True{}:
      P

law faithful:
  for +outside: Bool
  for +value: Bool
  When(Bool.not(outside), {cell(value, outside) == value : Bool})

def faithful(outside, value):
  match outside:
    case False{}:
      {==}
    case True{}:
      Unit{}

law clamped:
  for +outside: Bool
  for +value: Bool
  When(outside, {cell(value, outside) == False{} : Bool})

def clamped(outside, value):
  match outside:
    case False{}:
      Unit{}
    case True{}:
      {==}
