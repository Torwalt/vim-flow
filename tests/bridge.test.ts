import { describe, expect, test } from "bun:test";
import Scene from "../src/core/scene.bend";

describe("Bend to JavaScript boundary", () => {
  test("exports dimensions as JS numbers and cells as tagged objects", () => {
    expect(Scene.columns()).toBe(40);
    expect(Scene.rows()).toBe(20);
    expect(Scene.cell(0, 8)).toEqual({ $: "Wall" });
    expect(Scene.cell(8, 8)).toEqual({ $: "Floor" });
    expect(Scene.glyph(Scene.cell(0, 8))).toBe("#");
    expect(Scene.glyph(Scene.cell(8, 8))).toBe(".");
  });
});
