import http from 'node:http';
import { spawn } from 'node:child_process';
import { randomUUID } from 'node:crypto';

const host = process.env.PI_BRIDGE_HOST ?? '0.0.0.0';
const port = Number(process.env.PI_BRIDGE_PORT ?? '8787');
const workspace = process.env.PI_WORKSPACE ?? '/workspace/pixelgridOS';
const sessionDir = process.env.PI_SESSION_DIR ?? '/pi-sessions';
const token = process.env.PI_BRIDGE_TOKEN ?? '';

const piArgs = ['--mode', 'rpc', '--session-dir', sessionDir];
if (process.env.PI_PROVIDER) {
  piArgs.push('--provider', process.env.PI_PROVIDER);
}
if (process.env.PI_MODEL) {
  piArgs.push('--model', process.env.PI_MODEL);
}
if (process.env.PI_NO_SESSION === 'true') {
  piArgs.push('--no-session');
}

console.error(`[pi-bridge] starting: pi ${piArgs.join(' ')}`);
console.error(`[pi-bridge] cwd: ${workspace}`);

const pi = spawn('pi', piArgs, {
  cwd: workspace,
  env: process.env,
  stdio: ['pipe', 'pipe', 'pipe'],
});

const pending = new Map();
let buffer = '';
let lastState = { ready: false, isStreaming: false, sessionFile: null, messageCount: 0 };

pi.on('spawn', () => {
  lastState.ready = true;
  console.error('[pi-bridge] pi rpc process started');
});

pi.on('exit', (code, signal) => {
  lastState.ready = false;
  console.error(`[pi-bridge] pi rpc exited code=${code} signal=${signal}`);
  for (const [id, request] of pending) {
    request.reject(new Error('pi rpc process exited'));
    pending.delete(id);
  }
});

pi.stderr.on('data', (chunk) => {
  process.stderr.write(`[pi] ${chunk}`);
});

pi.stdout.on('data', (chunk) => {
  buffer += chunk.toString('utf8');
  let newlineIndex;
  while ((newlineIndex = buffer.indexOf('\n')) >= 0) {
    const rawLine = buffer.slice(0, newlineIndex).replace(/\r$/, '');
    buffer = buffer.slice(newlineIndex + 1);
    if (!rawLine.trim()) continue;
    handlePiLine(rawLine);
  }
});

function handlePiLine(rawLine) {
  let message;
  try {
    message = JSON.parse(rawLine);
  } catch (error) {
    console.error(`[pi-bridge] non-json pi stdout: ${rawLine}`);
    return;
  }

  if (message.type === 'response') {
    if (message.command === 'get_state' && message.success && message.data) {
      lastState = { ready: true, ...message.data };
    }
    if (message.id && pending.has(message.id)) {
      const request = pending.get(message.id);
      clearTimeout(request.timeout);
      pending.delete(message.id);
      request.resolve(message);
    }
    return;
  }

  // Keep Docker logs useful without exposing the whole RPC protocol to clients.
  if (message.type === 'assistant_delta' && typeof message.delta === 'string') {
    process.stderr.write(message.delta);
  } else if (message.type !== 'assistant_delta') {
    console.error(`[pi-event] ${JSON.stringify(message)}`);
  }
}

function sendRpc(command, timeoutMs = 15000) {
  if (!lastState.ready || pi.killed || !pi.stdin.writable) {
    return Promise.reject(new Error('pi rpc process is not ready'));
  }

  const id = command.id ?? randomUUID();
  const payload = { id, ...command };

  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`timed out waiting for pi response to ${payload.type}`));
    }, timeoutMs);

    pending.set(id, { resolve, reject, timeout });
    pi.stdin.write(`${JSON.stringify(payload)}\n`, (error) => {
      if (error) {
        clearTimeout(timeout);
        pending.delete(id);
        reject(error);
      }
    });
  });
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => {
      body += chunk;
      if (body.length > 1024 * 1024) {
        reject(new Error('request body too large'));
        req.destroy();
      }
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch {
        reject(new Error('invalid json body'));
      }
    });
    req.on('error', reject);
  });
}

function writeJson(res, status, payload) {
  res.writeHead(status, {
    'content-type': 'application/json',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
    'access-control-allow-headers': 'content-type,authorization,x-pi-token',
  });
  res.end(JSON.stringify(payload));
}

function authorized(req) {
  if (!token) return true;
  return req.headers.authorization === `Bearer ${token}` || req.headers['x-pi-token'] === token;
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    writeJson(res, 204, {});
    return;
  }

  if (!authorized(req)) {
    writeJson(res, 401, { ok: false, error: 'unauthorized' });
    return;
  }

  try {
    if (req.method === 'GET' && req.url === '/health') {
      writeJson(res, 200, { ok: true, ready: lastState.ready, workspace });
      return;
    }

    if (req.method === 'GET' && req.url === '/state') {
      try {
        const response = await sendRpc({ type: 'get_state' });
        writeJson(res, response.success ? 200 : 500, response);
      } catch (error) {
        writeJson(res, 500, { ok: false, error: String(error.message ?? error), state: lastState });
      }
      return;
    }

    if (req.method === 'POST' && req.url === '/prompt') {
      const body = await readJsonBody(req);
      const message = String(body.message ?? '').trim();
      if (!message) {
        writeJson(res, 400, { ok: false, error: 'message is required' });
        return;
      }

      const response = await sendRpc({
        type: 'prompt',
        message,
        streamingBehavior: body.streamingBehavior ?? 'followUp',
      });
      writeJson(res, response.success ? 202 : 500, { ok: response.success, response });
      return;
    }

    writeJson(res, 404, { ok: false, error: 'not found' });
  } catch (error) {
    writeJson(res, 500, { ok: false, error: String(error.message ?? error) });
  }
});

server.listen(port, host, () => {
  console.error(`[pi-bridge] listening on http://${host}:${port}`);
});

process.on('SIGTERM', () => {
  server.close();
  pi.kill('SIGTERM');
});
