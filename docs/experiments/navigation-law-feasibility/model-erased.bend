import Base

def cell(+value: Bool, outside: Bool) -> Bool:
  match outside:
    case False{}:
      value
    case True{}:
      False{}

law faithful:
  for +value: Bool
  for +outside: Bool
  for -ok: {outside == False{} : Bool}
  {cell(value, outside) == value : Bool}

def faithful(value, outside, ok):
  %ok : {cell(value, outside) == cell(value, _) : Bool}
  {==}

law clamped:
  for +value: Bool
  for +outside: Bool
  for -ok: {outside == True{} : Bool}
  {cell(value, outside) == False{} : Bool}

def clamped(value, outside, ok):
  %ok : {cell(value, outside) == cell(value, _) : Bool}
  {==}
