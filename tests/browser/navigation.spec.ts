import type { Page } from "@playwright/test";
import { expect, test } from "./test";

type Snapshot = {
  position: number;
  row: number;
  column: number;
  mode: string;
  count: number;
  contents: string;
};

type Rgb = [number, number, number, number];

async function open(page: Page): Promise<void> {
  await page.goto("/");
  await expect(page.locator("#world")).toHaveAttribute("data-ready", "true");
  await page.locator("#world").focus();
}

async function snapshot(page: Page): Promise<Snapshot> {
  return page.locator("#world").evaluate((element) => {
    const canvas = element as HTMLCanvasElement;
    return {
      position: Number(canvas.dataset.position),
      row: Number(canvas.dataset.row),
      column: Number(canvas.dataset.column),
      mode: canvas.dataset.mode ?? "",
      count: Number(canvas.dataset.count),
      contents: canvas.dataset.contents ?? "",
    };
  });
}

async function cellColor(page: Page, column: number, row: number): Promise<Rgb> {
  return page.locator("#world").evaluate((element, cell) => {
    const canvas = element as HTMLCanvasElement;
    const context = canvas.getContext("2d")!;
    const cellWidth = canvas.width / 40;
    const cellHeight = canvas.height / 20;
    const x = Math.floor(cell.column * cellWidth + 3 * (canvas.width / 800));
    const y = Math.floor(cell.row * cellHeight + 3 * (canvas.height / 480));
    const data = context.getImageData(x, y, 1, 1).data;
    return [data[0], data[1], data[2], data[3]] as Rgb;
  }, { column, row });
}

function brightness(color: Rgb): number {
  return color[0] + color[1] + color[2];
}

async function press(page: Page, ...keys: string[]): Promise<void> {
  for (const key of keys) await page.keyboard.press(key);
}

test("renders the seeded field and a distinct cursor", async ({ page }) => {
  await open(page);
  const initial = await snapshot(page);
  expect(initial.position).toBe(0);
  expect(initial.row).toBe(0);
  expect(initial.column).toBe(0);
  expect(initial.mode).toBe("Normal");
  expect(initial.count).toBe(0);
  expect(initial.contents.length).toBe(800);
  expect(initial.contents.slice(0, 40)).toBe('alpha beta  foo_bar ++ 42 "quote"       ');
  expect(initial.contents.slice(80, 120)).toBe(" ".repeat(40));
  await expect(page.locator("#status-mode")).toHaveText("NORMAL");
  await expect(page.locator("#status-detail")).toHaveText("row 1 · col 1");

  const cursor = await cellColor(page, 0, 0);
  const field = await cellColor(page, 0, 1);
  expect(cursor).not.toEqual(field);
  expect(brightness(cursor)).toBeGreaterThan(brightness(field) + 100);
});

test("5j and 3G move a real cursor pixel with the reported position", async ({ page }) => {
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await open(page);
  const initial = await snapshot(page);
  const cursorColor = await cellColor(page, initial.column, initial.row);
  const fieldColor = await cellColor(page, 0, 1);

  await press(page, "5", "j");
  const fiveDown = await snapshot(page);
  expect(fiveDown.position).toBe(5 * 40);
  expect(fiveDown.row).toBe(5);
  expect(fiveDown.column).toBe(0);
  expect(fiveDown.mode).toBe("Normal");
  expect(fiveDown.count).toBe(0);
  expect(await cellColor(page, 0, 5)).toEqual(cursorColor);
  expect(await cellColor(page, 0, 0)).toEqual(fieldColor);

  await press(page, "3", "G");
  const thirdRow = await snapshot(page);
  expect(thirdRow.position).toBe(2 * 40);
  expect(thirdRow.row).toBe(2);
  expect(thirdRow.column).toBe(0);
  expect(await cellColor(page, 0, 2)).toEqual(cursorColor);
  expect(await cellColor(page, 0, 5)).toEqual(fieldColor);
  expect(errors).toEqual([]);
});

test("Shift+w, 2fx, F and gg keep case and preserve the field", async ({ page }) => {
  await open(page);
  const initial = await snapshot(page);
  const cursorColor = await cellColor(page, 0, 0);

  await page.keyboard.press("Shift+w");
  const bigWord = await snapshot(page);
  expect(bigWord.position).toBe(6);
  expect(bigWord.mode).toBe("Normal");
  expect(await cellColor(page, 6, 0)).toEqual(cursorColor);

  await press(page, "j");
  expect((await snapshot(page)).position).toBe(40 + 6);
  await press(page, "2", "f", "x");
  const secondFind = await snapshot(page);
  expect(secondFind.position).toBe(40 + 31);
  expect(secondFind.mode).toBe("Normal");
  expect(await cellColor(page, 31, 1)).toEqual(cursorColor);

  await press(page, "$", "F", "o");
  const backwardsFind = await snapshot(page);
  expect(backwardsFind.position).toBe(40 + 9);
  expect(backwardsFind.mode).toBe("Normal");

  await press(page, "g", "g");
  const firstRow = await snapshot(page);
  expect(firstRow.position).toBe(0);
  expect(firstRow.row).toBe(0);
  expect(await cellColor(page, 0, 0)).toEqual(cursorColor);
  expect(firstRow.contents).toBe(initial.contents);
});

test("Escape clears pending input and blocked chords leave it alone", async ({ page }) => {
  await open(page);

  await press(page, "2");
  const pending = await snapshot(page);
  expect(pending.mode).toBe("Normal");
  expect(pending.count).toBe(2);
  await expect(page.locator("#status-mode")).toHaveText("NORMAL · COUNT 2");

  await page.keyboard.press("Control+j");
  const blocked = await snapshot(page);
  expect(blocked.position).toBe(0);
  expect(blocked.mode).toBe("Normal");
  expect(blocked.count).toBe(2);

  await press(page, "Escape");
  const cleared = await snapshot(page);
  expect(cleared.position).toBe(0);
  expect(cleared.count).toBe(0);
  await expect(page.locator("#status-mode")).toHaveText("NORMAL");

  await press(page, "2", "j");
  expect((await snapshot(page)).position).toBe(2 * 40);

  await press(page, "3");
  await page.keyboard.press("Control+Escape");
  expect((await snapshot(page)).count).toBe(3);
  await press(page, "Escape");
  expect((await snapshot(page)).count).toBe(0);
});

test("pending find state is visible without changing the field", async ({ page }) => {
  await open(page);
  const initial = await snapshot(page);
  await press(page, "f");
  const pending = await snapshot(page);
  expect(pending.position).toBe(0);
  expect(pending.mode).toBe("FindRight");
  expect(pending.count).toBe(1);
  await expect(page.locator("#status-mode")).toHaveText("FIND RIGHT · COUNT 1");
  expect(pending.contents).toBe(initial.contents);
  await press(page, "o");
  expect((await snapshot(page)).position).toBe(13);
});
