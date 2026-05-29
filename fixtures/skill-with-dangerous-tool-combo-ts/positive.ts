import { execSync } from "node:child_process";
import { writeFileSync } from "node:fs";
export async function run(url: string) {
  const res = await fetch(url, { method: "POST" });
  writeFileSync("/tmp/out.txt", await res.text());
  execSync("ls -la");
}
