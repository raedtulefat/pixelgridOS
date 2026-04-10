#!/usr/bin/env node

// Minimal HTTP JSON endpoint to write kanban notes on tux.
// POST /api/kanban-note  {"text":"..."}

const http = require("http");
const fs = require("fs");
const path = require("path");

const HOST = "127.0.0.1";
const PORT = process.env.PORT ? Number(process.env.PORT) : 8787;
const OUT_DIR = "/home/boris-agent/apps/roguechoices/kanban/1-TODO";

function tsName(d = new Date()) {
  const pad = (n) => String(n).padStart(2, "0");
  return (
    d.getFullYear() +
    pad(d.getMonth() + 1) +
    pad(d.getDate()) +
    pad(d.getHours()) +
    pad(d.getMinutes()) +
    pad(d.getSeconds())
  );
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function writeUniqueTimestampedFile(text) {
  // Must follow YYYYMMDDHHMMSS.md. If multiple submissions happen within the
  // same second, retry on the next second.
  for (let attempt = 0; attempt < 3; attempt++) {
    const name = `${tsName()}.md`;
    const outPath = path.join(OUT_DIR, name);
    try {
      await fs.promises.writeFile(outPath, text + "\n", {
        encoding: "utf8",
        flag: "wx",
      });
      return outPath;
    } catch (e) {
      if (e && e.code === "EEXIST") {
        await sleep(1000);
        continue;
      }
      throw e;
    }
  }
  throw new Error("timestamp_collision");
}

const server = http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/api/kanban-note") {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 2 * 1024 * 1024) req.destroy(); // 2MB cap
    });
    req.on("end", async () => {
      try {
        const data = JSON.parse(body || "{}");
        const text = String(data.text || "").trim();
        if (!text) {
          res.writeHead(400, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ ok: false, error: "empty_text" }));
          return;
        }

        await fs.promises.mkdir(OUT_DIR, { recursive: true });
        const outPath = await writeUniqueTimestampedFile(text);

        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ ok: true, path: outPath }));
      } catch (e) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ ok: false, error: "server_error" }));
      }
    });
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ ok: false, error: "not_found" }));
});

server.listen(PORT, HOST, () => {
  console.log(`kanban-note-server listening on http://${HOST}:${PORT}`);
});
