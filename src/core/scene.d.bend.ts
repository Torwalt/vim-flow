export type Cell = { $: "Floor" } | { $: "Wall" };

declare const Scene: {
  columns(): number;
  rows(): number;
  cell(column: number, row: number): Cell;
  glyph(value: Cell): string;
};

export default Scene;
