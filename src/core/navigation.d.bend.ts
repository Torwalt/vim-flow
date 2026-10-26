export type State = { readonly __navigationState: unique symbol };
export type Field = { readonly __navigationField: unique symbol };
export type Input = { readonly __navigationInput: unique symbol };
export type View = { readonly __navigationView: unique symbol };

export type Mode =
  | { $: "Normal"; count: number }
  | { $: "FindRight"; count: number }
  | { $: "FindLeft"; count: number }
  | { $: "Go"; count: number };

declare const Navigation: {
  initial(): State;
  step(state: State, input: Input): State;
  view(state: State): View;
  board(state: State): Field;
  position(state: State): number;
  mode(state: State): Mode;
  contents(state: State): string;
  valid(state: State): boolean;
  columns(): number;
  rows(): number;
  input_character(text: string, blocked: boolean): Input;
  input_escape(blocked: boolean): Input;
  input_other(): Input;
};

export default Navigation;
