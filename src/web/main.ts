import Navigation from "../core/navigation.bend";
import type { Mode } from "../core/navigation.d.bend";

const canvas = document.querySelector<HTMLCanvasElement>("#world");
if (!canvas) throw new Error("The world canvas is missing.");
const context = canvas.getContext("2d");
if (!context) throw new Error("Canvas 2D is unavailable.");
const statusMode = document.querySelector<HTMLElement>("#status-mode");
const statusDetail = document.querySelector<HTMLElement>("#status-detail");

const columns = Navigation.columns();
const rows = Navigation.rows();
const cellWidth = 20;
const cellHeight = 24;
const width = columns * cellWidth;
const height = rows * cellHeight;
const fieldBackground = "#111714";
const fieldGlyph = "#8ea181";
const cursorBackground = "#d8f28a";
const cursorGlyph = "#111714";

let state = Navigation.initial();

function modeLabel(mode: Mode): string {
  switch (mode.$) {
    case "Normal":
      return mode.count > 0 ? `NORMAL · COUNT ${mode.count}` : "NORMAL";
    case "FindRight":
      return `FIND RIGHT · COUNT ${mode.count}`;
    case "FindLeft":
      return `FIND LEFT · COUNT ${mode.count}`;
    case "Go":
      return mode.count > 0 ? `GO · COUNT ${mode.count}` : "GO";
  }
}

function draw(): void {
  if (!canvas || !context) return;
  const ratio = window.devicePixelRatio || 1;
  canvas.width = Math.round(width * ratio);
  canvas.height = Math.round(height * ratio);
  context.setTransform(ratio, 0, 0, ratio, 0, 0);
  context.fillStyle = fieldBackground;
  context.fillRect(0, 0, width, height);
  context.font = '15px "SFMono-Regular", Consolas, "Liberation Mono", monospace';
  context.textAlign = "center";
  context.textBaseline = "middle";

  const contents = Navigation.contents(state);
  const position = Navigation.position(state);
  const mode = Navigation.mode(state);
  const cursorColumn = position % columns;
  const cursorRow = Math.floor(position / columns);

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      const glyph = contents[row * columns + column] ?? " ";
      const cursor = row === cursorRow && column === cursorColumn;
      if (cursor) {
        context.fillStyle = cursorBackground;
        context.fillRect(column * cellWidth, row * cellHeight, cellWidth, cellHeight);
      }
      context.fillStyle = cursor ? cursorGlyph : fieldGlyph;
      context.fillText(glyph, column * cellWidth + cellWidth / 2, row * cellHeight + cellHeight / 2);
    }
  }

  if (statusMode) statusMode.textContent = modeLabel(mode);
  if (statusDetail) statusDetail.textContent = `row ${cursorRow + 1} · col ${cursorColumn + 1}`;
  canvas.dataset.position = String(position);
  canvas.dataset.row = String(cursorRow);
  canvas.dataset.column = String(cursorColumn);
  canvas.dataset.mode = mode.$;
  canvas.dataset.count = String(mode.count);
  canvas.dataset.contents = contents;
  canvas.dataset.ready = "true";
}

function ownsFocus(): boolean {
  return document.activeElement === canvas;
}

function editableTarget(target: EventTarget | null): boolean {
  const element = target instanceof HTMLElement ? target : null;
  return Boolean(element && (element.isContentEditable ||
    element.tagName === "INPUT" || element.tagName === "TEXTAREA" || element.tagName === "SELECT"));
}

function handleKey(event: KeyboardEvent): void {
  if (event.defaultPrevented || event.isComposing || event.keyCode === 229) return;
  if (!ownsFocus() || editableTarget(event.target)) return;
  const blocked = event.ctrlKey || event.altKey || event.metaKey;
  if (event.key === "Escape") {
    event.preventDefault();
    state = Navigation.step(state, Navigation.input_escape(blocked));
    draw();
    return;
  }
  if (Array.from(event.key).length !== 1) return;
  event.preventDefault();
  state = Navigation.step(state, Navigation.input_character(event.key, blocked));
  draw();
}

function handleCompositionEnd(event: CompositionEvent): void {
  if (!ownsFocus() || Array.from(event.data).length !== 1) return;
  state = Navigation.step(state, Navigation.input_character(event.data, false));
  draw();
}

canvas.addEventListener("pointerdown", () => canvas.focus());
window.addEventListener("keydown", handleKey);
window.addEventListener("compositionend", handleCompositionEnd);
window.addEventListener("resize", draw);

draw();
canvas.focus();
