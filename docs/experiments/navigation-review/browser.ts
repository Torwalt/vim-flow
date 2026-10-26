import { chromium } from '@playwright/test';
const repoRoot=new URL('../../../', import.meta.url).pathname;
const server=Bun.spawn(['bun','tools/preview.ts'],{cwd:repoRoot,env:{...process.env,PORT:'43187'},stdout:'ignore',stderr:'inherit'});
let browser;
try {
  for(let i=0;i<100;i++) { try { if((await fetch('http://localhost:43187')).ok) break; } catch {} await Bun.sleep(50); }
  browser=await chromium.launch({executablePath:process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH});
  const page=await browser.newPage();
  await page.goto('http://localhost:43187');
  await page.locator('#world[data-ready="true"]').waitFor();
  await page.keyboard.press('f');
  await page.evaluate(()=>window.dispatchEvent(new Event('blur')));
  console.log('mode after f + window blur:',await page.locator('#world').getAttribute('data-mode'));
  await page.keyboard.press('Escape');
  await page.keyboard.press('9');
  await page.keyboard.press('9');
  const start=performance.now();
  await page.keyboard.press('w');
  await page.waitForFunction(()=>document.querySelector('#world')?.getAttribute('data-count')==='0');
  console.log('production Chromium 99w milliseconds:',Math.round(performance.now()-start));
  console.log('position:',await page.locator('#world').getAttribute('data-position'));
} finally { await browser?.close(); server.kill(); await server.exited; }
