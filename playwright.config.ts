import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/browser",
  fullyParallel: true,
  use: {
    browserName: "chromium",
    launchOptions: {
      executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH || undefined,
    },
    trace: "retain-on-failure",
  },
  projects: [
    { name: "development", use: { baseURL: "http://localhost:3000" } },
    { name: "production", use: { baseURL: "http://localhost:4173" } },
  ],
  webServer: [
    {
      command: "bun run dev",
      url: "http://localhost:3000",
      reuseExistingServer: false,
      timeout: 30_000,
    },
    {
      command: "bun run preview",
      url: "http://localhost:4173",
      reuseExistingServer: false,
      timeout: 30_000,
    },
  ],
});
