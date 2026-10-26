import { resolve } from "node:path";

const root = resolve(import.meta.dir, "..");
const mode = process.argv[2] || "--frozen";
if (!["--frozen", "--pending", "--complete"].includes(mode)) {
  throw new Error("Use --frozen, --pending, or --complete.");
}

const manifest = await Bun.file(resolve(root, "spec/navigation/manifest.json")).json() as {
  openDeclarations: number;
  files: Record<string, string>;
};

let declarations = 0;
for (const [path, expected] of Object.entries(manifest.files)) {
  const source = await Bun.file(resolve(root, path)).text();
  const actual = new Bun.CryptoHasher("sha256").update(source).digest("hex");
  if (actual !== expected) throw new Error(`Frozen navigation contract changed: ${path}`);
  declarations += [...source.matchAll(/^law /gm)].length;
}
if (declarations !== manifest.openDeclarations) throw new Error("Contract declaration count changed.");
console.log(`Frozen navigation contract: ${declarations} declarations intact.`);

async function bend(args: string[]): Promise<{ status: number; output: string }> {
  const process = Bun.spawn(["bend", ...args], { cwd: root, stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, status] = await Promise.all([
    new Response(process.stdout).text(),
    new Response(process.stderr).text(),
    process.exited,
  ]);
  return { status, output: stdout + stderr };
}

if (mode === "--pending") {
  const result = await bend(["spec/navigation/ALL.bend", "--check-only"]);
  const expected = `SOME PROOFS FAIL\nError: ${declarations} TODOs found.\nThe code is incomplete, and not a valid proof yet.`;
  if (result.status !== 1 || result.output.trim() !== expected) {
    throw new Error(`Expected only ${declarations} open declarations; received:\n${result.output}`);
  }
  console.log(`Contract elaborates; all ${declarations} declarations remain OPEN. This is not a proof pass.`);
}

if (mode === "--complete") {
  const laws = await Bun.file(resolve(root, "LAWS.bend")).text();
  if (!/^import \.\/spec\/navigation\/ALL\.bend as Navigation\s*$/m.test(laws)) {
    throw new Error("LAWS.bend must import the entire navigation contract as Navigation.");
  }
  const result = await bend(["PROOF.bend", "--verdict"]);
  if (result.status !== 0 || !result.output.includes("ALL PROOFS CHECK")) {
    throw new Error(`The full navigation contract is not proved:\n${result.output}`);
  }
  console.log("Full navigation contract imported and checked by --verdict.");
}
