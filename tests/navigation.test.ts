import { describe, expect, test } from "bun:test";
import Navigation from "../src/core/navigation.bend";

const normal = (count = 0): { $: "Normal"; count: number } => ({ $: "Normal", count });

function key(text: string, blocked = false) {
  return Navigation.input_character(text, blocked);
}

function press(state: ReturnType<typeof Navigation.initial>, text: string, blocked = false) {
  return Navigation.step(state, key(text, blocked));
}

function keys(state: ReturnType<typeof Navigation.initial>, texts: string[]) {
  return texts.reduce((current, text) => press(current, text), state);
}

describe("navigation input boundary", () => {
  test("initial state is the contracted seed with a valid observable view", () => {
    const state = Navigation.initial();
    expect(Navigation.position(state)).toBe(0);
    expect(Navigation.mode(state)).toEqual(normal());
    expect(Navigation.valid(state)).toBe(true);
    const contents = Navigation.contents(state);
    expect(contents.length).toBe(800);
    expect(contents.slice(0, 40)).toBe('alpha beta  foo_bar ++ 42 "quote"       ');
    expect(contents.slice(80, 120)).toBe(" ".repeat(40));
  });

  test("counts accumulate, saturate, clear and distinguish zero", () => {
    const ten = keys(Navigation.initial(), ["1", "0", "j"]);
    expect(Navigation.position(ten)).toBe(10 * 40);
    expect(Navigation.mode(ten)).toEqual(normal());

    const saturated = keys(Navigation.initial(), ["9", "9", "9", "9", "9", "l"]);
    expect(Navigation.position(saturated)).toBe(39);
    expect(Navigation.mode(saturated)).toEqual(normal());

    const zero = press(Navigation.initial(), "0");
    expect(Navigation.position(zero)).toBe(0);
    expect(Navigation.mode(zero)).toEqual(normal());

    const cleared = keys(Navigation.initial(), ["2", "x", "l"]);
    expect(Navigation.position(cleared)).toBe(1);
    expect(Navigation.mode(cleared)).toEqual(normal());

    const escaped = Navigation.step(press(Navigation.initial(), "2"),
      Navigation.input_escape(false));
    const afterEscape = press(escaped, "j");
    expect(Navigation.position(afterEscape)).toBe(40);
    expect(Navigation.mode(afterEscape)).toEqual(normal());
  });

  test("lowercase and uppercase motions stay distinct", () => {
    const rowOne = keys(Navigation.initial(), ["j", "6", "l"]);
    expect(Navigation.position(rowOne)).toBe(40 + 6);
    const small = press(rowOne, "w");
    const big = press(rowOne, "W");
    expect(Navigation.position(small)).toBe(40 + 7);
    expect(Navigation.position(big)).toBe(40 + 18);

    const smallEnd = press(rowOne, "e");
    const bigEnd = press(rowOne, "E");
    expect(Navigation.position(smallEnd)).toBe(40 + 7);
    expect(Navigation.position(bigEnd)).toBe(40 + 15);

    const uppercaseH = press(Navigation.initial(), "H");
    expect(Navigation.position(uppercaseH)).toBe(0);
    expect(Navigation.mode(uppercaseH)).toEqual(normal());
  });

  test("find consumes a literal target and preserves the cursor on a miss", () => {
    const second = press(press(Navigation.initial(), "2"), "f");
    expect(Navigation.mode(second)).toEqual({ $: "FindRight", count: 2 });
    const found = press(second, "o");
    expect(Navigation.position(found)).toBe(14);
    expect(Navigation.mode(found)).toEqual(normal());

    const miss = keys(Navigation.initial(), ["4", "f", "o"]);
    expect(Navigation.position(miss)).toBe(0);
    expect(Navigation.mode(miss)).toEqual(normal());

    const digitTarget = keys(Navigation.initial(), ["f", "4"]);
    expect(Navigation.position(digitTarget)).toBe(23);

    const spaceTarget = keys(Navigation.initial(), ["f", " "]);
    expect(Navigation.position(spaceTarget)).toBe(5);

    const motionTarget = keys(Navigation.initial(), ["f", "f"]);
    expect(Navigation.position(motionTarget)).toBe(12);

    const backwards = keys(Navigation.initial(), ["$", "2", "F"]);
    expect(Navigation.mode(backwards)).toEqual({ $: "FindLeft", count: 2 });
    const backwardsFound = press(backwards, "o");
    expect(Navigation.position(backwardsFound)).toBe(14);
  });

  test("go prefix completes, rejects other keys and respects counts", () => {
    const goInvalid = keys(Navigation.initial(), ["g", "x"]);
    expect(Navigation.position(goInvalid)).toBe(0);
    expect(Navigation.mode(goInvalid)).toEqual(normal());

    const goEscaped = Navigation.step(press(Navigation.initial(), "g"),
      Navigation.input_escape(false));
    expect(Navigation.position(goEscaped)).toBe(0);
    expect(Navigation.mode(goEscaped)).toEqual(normal());

    const secondRow = keys(Navigation.initial(), ["2", "g", "g"]);
    expect(Navigation.position(secondRow)).toBe(40 + 2);
    expect(Navigation.mode(secondRow)).toEqual(normal());

    const thirdRowEnd = keys(Navigation.initial(), ["3", "G", "$"]);
    expect(Navigation.position(thirdRowEnd)).toBe(2 * 40 + 39);

    const lastRow = press(Navigation.initial(), "G");
    expect(Navigation.position(lastRow)).toBe(19 * 40);
    const firstRowAgain = keys(Navigation.initial(), ["G", "g", "g"]);
    expect(Navigation.position(firstRowAgain)).toBe(0);
  });

  test("blocked, nonprintable and escape input follow the pending state", () => {
    const pending = press(Navigation.initial(), "2");
    const blocked = press(pending, "j", true);
    expect(Navigation.position(blocked)).toBe(0);
    expect(Navigation.mode(blocked)).toEqual({ $: "Normal", count: 2 });
    expect(Navigation.position(press(blocked, "j"))).toBe(2 * 40);

    const nonprintable = press(Navigation.initial(), "\u0001");
    expect(Navigation.position(nonprintable)).toBe(0);
    expect(Navigation.mode(nonprintable)).toEqual(normal());

    const blockedEscape = Navigation.step(pending, Navigation.input_escape(true));
    expect(Navigation.mode(blockedEscape)).toEqual({ $: "Normal", count: 2 });
    const plainEscape = Navigation.step(blockedEscape, Navigation.input_escape(false));
    expect(Navigation.position(plainEscape)).toBe(0);
    expect(Navigation.mode(plainEscape)).toEqual(normal());

    const other = Navigation.step(pending, Navigation.input_other());
    expect(Navigation.position(other)).toBe(0);
    expect(Navigation.mode(other)).toEqual({ $: "Normal", count: 2 });

    const modifierOnly = Navigation.step(pending, Navigation.input_character("Shift", true));
    expect(Navigation.mode(modifierOnly)).toEqual({ $: "Normal", count: 2 });

    const allSpace = Navigation.step(keys(Navigation.initial(), ["3", "G"]),
      Navigation.input_escape(false));
    expect(Navigation.position(press(allSpace, "^"))).toBe(2 * 40);
  });

  test("movement clamps at field edges and preserves the field", () => {
    const left = press(Navigation.initial(), "h");
    expect(Navigation.position(left)).toBe(0);
    const up = press(Navigation.initial(), "k");
    expect(Navigation.position(up)).toBe(0);

    const bottom = press(Navigation.initial(), "G");
    expect(Navigation.position(press(bottom, "j"))).toBe(19 * 40);
    expect(Navigation.position(press(bottom, "l"))).toBe(19 * 40 + 1);

    const right = keys(Navigation.initial(), ["$", "l"]);
    expect(Navigation.position(right)).toBe(39);

    const before = Navigation.contents(Navigation.initial());
    const after = Navigation.contents(keys(Navigation.initial(), ["G", "2", "W", "f", "x"]));
    expect(after).toBe(before);
  });
});
