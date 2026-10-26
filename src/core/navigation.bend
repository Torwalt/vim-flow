import Base
import ../../PROOF.bend as Proof
import ../../spec/navigation/model.bend as Model
import ../../spec/navigation/input.bend as Input

def initial() -> Model.State:
  Model.initial()

def step(state: Model.State, input: Model.Input) -> Model.State:
  Input.step(state, input)

def view(state: Model.State) -> Model.View:
  Model.view(state)

def board(state: Model.State) -> Model.Field:
  Model.board(Model.view(state))

def position(state: Model.State) -> Nat:
  Model.position(Model.view(state))

def mode(state: Model.State) -> Model.Mode:
  Model.mode(Model.view(state))

def contents(state: Model.State) -> String:
  Model.contents(Model.board(Model.view(state)))

def valid(state: Model.State) -> Bool:
  Model.valid(Model.view(state))

def columns() -> U32:
  40

def rows() -> U32:
  20

def input_character(text: String, blocked: Bool) -> Model.Input:
  match text:
    case SNil{}:
      Model.Other{}
    case SCon{+ch, rest}:
      match rest:
        case SNil{}:
          Model.Character{ch, blocked}
        case SCon{_, _}:
          Model.Other{}

def input_escape(blocked: Bool) -> Model.Input:
  Model.Escape{blocked}

def input_other() -> Model.Input:
  Model.Other{}
