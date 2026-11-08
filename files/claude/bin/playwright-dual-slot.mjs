#!/usr/bin/env node
/**
 * Playwright MCP dual-slot launcher (Linux / Claude Code 版)
 *
 * Keeps two Chromium instances (CDP ports) ready for concurrent Claude sessions.
 * First AI window claims the free slot; the next window takes the other.
 *
 * stdio is fully delegated to @playwright/mcp (MCP protocol stays intact).
 * Diagnostics go to stderr only.
 */

import { spawn } from "node:child_process";
import fs from "node:fs";
import http from "node:http";
import net from "node:net";
import os from "node:os";
import path from "node:path";

// 常规调试口：先开的 AI 占 9222，后开的占闲置的 9223
const PORTS = [9222, 9223];
const XDG_DATA = process.env.XDG_DATA_HOME || path.join(os.homedir(), ".local", "share");
const BASE_DIR = path.join(XDG_DATA, "mcp-shared-browsers");
const LOCK_DIR = path.join(BASE_DIR, "locks");

// 找 Playwright 自带 Chromium（版本号目录会随更新变化，动态取最新的）
function findPlaywrightChromium() {
  const cache = path.join(os.homedir(), ".cache", "ms-playwright");
  let best = null;
  try {
    for (const entry of fs.readdirSync(cache)) {
      if (!entry.startsWith("chromium-")) continue;
      for (const sub of ["chrome-linux64", "chrome-linux"]) {
        const bin = path.join(cache, entry, sub, "chrome");
        try {
          if (fs.existsSync(bin)) {
            if (!best || entry > best.entry) best = { entry, bin };
          }
        } catch { /* ignore */ }
      }
    }
  } catch { /* ignore */ }
  return best ? best.bin : null;
}

const CHROME_CANDIDATES = [
  process.env.CHROME_PATH,
  findPlaywrightChromium(),
  "/usr/bin/google-chrome",
  "/usr/bin/google-chrome-stable",
  "/usr/bin/chromium",
  "/usr/bin/chromium-browser",
  "/usr/bin/microsoft-edge",
  "/snap/bin/chromium",
].filter(Boolean);

const EXTRA_MCP_ARGS = [
  "--browser=chrome",
  "--caps=vision,pdf",
];

function log(...args) {
  console.error("[playwright-dual-slot]", ...args);
}

function ensureDirs() {
  fs.mkdirSync(LOCK_DIR, { recursive: true });
  for (const port of PORTS) {
    fs.mkdirSync(path.join(BASE_DIR, `slot-${port}`), { recursive: true });
  }
}

function lockPath(port) {
  return path.join(LOCK_DIR, `slot-${port}.lock`);
}

function isPidAlive(pid) {
  if (!pid || !Number.isFinite(pid)) return false;
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

function readLock(port) {
  const file = lockPath(port);
  try {
    const raw = fs.readFileSync(file, "utf8").trim();
    const data = JSON.parse(raw);
    if (isPidAlive(data.pid)) return data;
    fs.unlinkSync(file);
    return null;
  } catch {
    try {
      fs.unlinkSync(file);
    } catch {
      /* ignore */
    }
    return null;
  }
}

function tryAcquireLock(port) {
  const file = lockPath(port);
  const existing = readLock(port);
  if (existing) return false;

  const payload = JSON.stringify(
    {
      pid: process.pid,
      port,
      startedAt: new Date().toISOString(),
    },
    null,
    0
  );

  try {
    const fd = fs.openSync(file, "wx");
    fs.writeFileSync(fd, payload);
    fs.closeSync(fd);
    // Re-read in case of rare race
    const again = JSON.parse(fs.readFileSync(file, "utf8"));
    if (again.pid !== process.pid) return false;
    return true;
  } catch {
    return false;
  }
}

function releaseLock(port) {
  const file = lockPath(port);
  try {
    const raw = fs.readFileSync(file, "utf8");
    const data = JSON.parse(raw);
    if (data.pid === process.pid) fs.unlinkSync(file);
  } catch {
    /* ignore */
  }
}

function findChrome() {
  for (const p of CHROME_CANDIDATES) {
    try {
      if (p && fs.existsSync(p)) return p;
    } catch {
      /* ignore */
    }
  }
  return null;
}

function portOpen(port) {
  return new Promise((resolve) => {
    const socket = net.connect({ host: "127.0.0.1", port }, () => {
      socket.end();
      resolve(true);
    });
    socket.on("error", () => resolve(false));
    socket.setTimeout(500, () => {
      socket.destroy();
      resolve(false);
    });
  });
}

function cdpVersion(port) {
  return new Promise((resolve) => {
    const req = http.get(
      {
        host: "127.0.0.1",
        port,
        path: "/json/version",
        timeout: 1500,
      },
      (res) => {
        let body = "";
        res.on("data", (c) => (body += c));
        res.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch {
            resolve(null);
          }
        });
      }
    );
    req.on("error", () => resolve(null));
    req.on("timeout", () => {
      req.destroy();
      resolve(null);
    });
  });
}

async function ensureChrome(port) {
  const version = await cdpVersion(port);
  if (version) {
    log(`Chrome already up on ${port}:`, version.Browser || "ok");
    return;
  }

  const chrome = findChrome();
  if (!chrome) {
    throw new Error(
      "Chrome/Chromium not found. Set CHROME_PATH or run: npx playwright install chromium"
    );
  }

  const userDataDir = path.join(BASE_DIR, `slot-${port}`);
  const args = [
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${userDataDir}`,
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-sync",
    "--no-sandbox",
    "about:blank",
  ];

  log(`Starting Chrome for slot ${port}:`, chrome);
  const child = spawn(chrome, args, {
    detached: true,
    stdio: "ignore",
  });
  child.unref();

  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    const v = await cdpVersion(port);
    if (v) {
      log(`Chrome ready on ${port}`);
      return;
    }
    await new Promise((r) => setTimeout(r, 300));
  }
  throw new Error(`Chrome CDP did not become ready on port ${port}`);
}

/**
 * Dual-slot: first free lock wins (9222 first, then 9223).
 * Do NOT steal another session's live CDP — each Claude window owns one port.
 * ensureChrome only starts Chrome if that port has no CDP yet; never kills browsers.
 */
function pickSlot() {
  for (const port of PORTS) {
    if (tryAcquireLock(port)) return port;
  }
  return null;
}

function runMcp(port) {
  const endpoint = `http://127.0.0.1:${port}`;
  const mcpArgs = [`--cdp-endpoint=${endpoint}`, ...EXTRA_MCP_ARGS];

  log(`Launching Playwright MCP → ${endpoint}`);
  log(`Slots: ${PORTS.join(", ")} | this session: ${port}`);

  // 本地固定版本优先：启动不查 npm 源，避免撞 Claude 默认 30s MCP_TIMEOUT（2026-09-20 00:45 事故）
  const localCli = path.join(
    os.homedir(),
    ".claude",
    "mcp-servers",
    "playwright-mcp-local",
    "node_modules",
    "@playwright",
    "mcp",
    "cli.js"
  );
  let command;
  let args;
  if (fs.existsSync(localCli)) {
    command = process.execPath;
    args = [localCli, ...mcpArgs];
    log(`Using local install: ${localCli}`);
  } else {
    const npx = process.env.NPX_PATH || "npx";
    command = npx;
    args = ["-y", "@playwright/mcp@latest", ...mcpArgs];
    log("Local install missing; falling back to npx @playwright/mcp@latest");
  }
  const child = spawn(command, args, {
    stdio: "inherit",
    env: process.env,
  });

  const cleanup = () => {
    releaseLock(port);
  };

  process.on("exit", cleanup);
  process.on("SIGINT", () => {
    cleanup();
    try {
      child.kill("SIGINT");
    } catch {
      /* ignore */
    }
    process.exit(130);
  });
  process.on("SIGTERM", () => {
    cleanup();
    try {
      child.kill("SIGTERM");
    } catch {
      /* ignore */
    }
    process.exit(143);
  });

  child.on("exit", (code, signal) => {
    cleanup();
    if (signal) process.exit(1);
    process.exit(code ?? 0);
  });

  child.on("error", (err) => {
    cleanup();
    log("Failed to start npx/@playwright/mcp:", err.message);
    process.exit(1);
  });
}

async function main() {
  ensureDirs();

  const port = pickSlot();
  if (port == null) {
    log(
      `Both slots busy (${PORTS.join(
        ", "
      )}). Close one Claude Playwright session and retry.`
    );
    for (const p of PORTS) {
      const lock = readLock(p);
      if (lock) log(`  port ${p} held by pid ${lock.pid} since ${lock.startedAt}`);
    }
    process.exit(2);
  }

  log(`Claimed slot port ${port} (pid ${process.pid})`);
  log(`Rule: 9222/9223 are independent sessions — never proxy or steal the other slot.`);

  try {
    // Only starts Chrome if CDP is down on THIS port — never kill other slot browsers
    await ensureChrome(port);
  } catch (err) {
    releaseLock(port);
    log(err.message || err);
    process.exit(1);
  }

  runMcp(port);
}

main().catch((err) => {
  log(err?.stack || err);
  process.exit(1);
});
