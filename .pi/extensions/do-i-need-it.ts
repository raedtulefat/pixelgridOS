import { access, stat } from "node:fs/promises";
import path from "node:path";

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

type ExecFn = ExtensionAPI["exec"];

type NeedItReport = {
  targetPath: string;
  rows: Array<{ item: string; status: "✅" | "❌" | "⚠️"; notes: string }>;
  recommendation: string;
};

type ExternalContribution = {
  source: string;
  content: string;
};

export default function doINeedItExtension(pi: ExtensionAPI) {
  const externalContributions: ExternalContribution[] = [];

  const addContribution = (payload: unknown) => {
    const parsed = parseContribution(payload);
    if (parsed == null) {
      return;
    }
    externalContributions.push(parsed);
  };

  pi.events.on("do-i-need-it:content", addContribution);

  pi.registerCommand("do-i-need-it-content", {
    description:
      "Add external content for do-i-need-it to display at session end.",
    handler: async (args, ctx) => {
      const text = args?.trim();
      if (!text) {
        ctx.ui.notify("Usage: /do-i-need-it-content <text>", "error");
        return;
      }
      addContribution({ source: "manual", content: text });
      ctx.ui.notify("Added do-i-need-it external content", "success");
    },
  });

  pi.on("session_shutdown", async (_event, _ctx) => {
    if (externalContributions.length == 0) {
      return;
    }

    const lines = externalContributions.map(
      (entry, index) => `- ${index + 1}. [${entry.source}] ${entry.content}`,
    );

    pi.sendMessage({
      customType: "do-i-need-it",
      content: [
        "External extension content received:",
        "",
        ...lines,
        "",
        "Recoomendation: keep it.",
      ].join("\n"),
      display: true,
    });
  });

  pi.registerCommand("do-i-need-it", {
    description:
      "Analyze whether a file/folder is needed, should be committed, and print a checkmark table.",
    handler: async (args, ctx) => {
      const rawInput = args?.trim();
      if (!rawInput) {
        ctx.ui.notify("Usage: /do-i-need-it <path>", "error");
        return;
      }

      const report = await buildReport({
        cwd: ctx.cwd,
        inputPath: rawInput,
        exec: pi.exec,
      });

      pi.sendMessage({
        customType: "do-i-need-it",
        content: renderReport(report),
        display: true,
      });
    },
  });

  pi.registerTool({
    name: "do_i_need_it",
    label: "Do I Need It",
    description:
      "Analyze whether a file/folder is needed and should be committed. Returns a checkmark table plus recommendation.",
    promptSnippet:
      "Use this tool when the user asks if a file/folder is needed, used, or should be committed.",
    parameters: Type.Object({
      path: Type.String({ description: "File or folder path to analyze" }),
      externalContent: Type.Optional(
        Type.String({
          description:
            "Optional content from other extensions to display at session end.",
        }),
      ),
      externalSource: Type.Optional(
        Type.String({
          description: "Optional source label for externalContent.",
          default: "external",
        }),
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (params.externalContent?.trim()) {
        addContribution({
          source: params.externalSource?.trim() || "external",
          content: params.externalContent.trim(),
        });
      }

      const report = await buildReport({
        cwd: ctx.cwd,
        inputPath: params.path,
        exec: pi.exec,
      });

      return {
        content: [{ type: "text", text: renderReport(report) }],
        details: report,
      };
    },
  });
}

function parseContribution(payload: unknown): ExternalContribution | null {
  if (typeof payload == "string") {
    const content = payload.trim();
    if (!content) {
      return null;
    }
    return { source: "external", content };
  }

  if (payload == null || typeof payload != "object") {
    return null;
  }

  const maybe = payload as { source?: unknown; content?: unknown; text?: unknown };
  const content =
    typeof maybe.content == "string"
      ? maybe.content.trim()
      : typeof maybe.text == "string"
        ? maybe.text.trim()
        : "";

  if (!content) {
    return null;
  }

  const source =
    typeof maybe.source == "string" && maybe.source.trim().length > 0
      ? maybe.source.trim()
      : "external";

  return { source, content };
}

async function buildReport(args: {
  cwd: string;
  inputPath: string;
  exec: ExecFn;
}): Promise<NeedItReport> {
  const resolvedPath = path.isAbsolute(args.inputPath)
    ? args.inputPath
    : path.resolve(args.cwd, args.inputPath);
  const relativePath = path.relative(args.cwd, resolvedPath) || ".";

  const exists = await pathExists(resolvedPath);
  const stats = exists ? await stat(resolvedPath) : null;
  const isDir = Boolean(stats?.isDirectory());

  const tracked = exists
    ? await isGitTracked(args.exec, args.cwd, relativePath)
    : false;
  const ignored = exists
    ? await isGitIgnored(args.exec, args.cwd, relativePath)
    : false;

  const purpose = inferPurpose(relativePath, isDir);
  const generated = isGeneratedPath(relativePath);

  const rows: NeedItReport["rows"] = [
    {
      item: "Path exists",
      status: exists ? "✅" : "❌",
      notes: exists
        ? isDir
          ? "Directory exists in project"
          : "File exists in project"
        : "Not found at this path",
    },
    {
      item: "Purpose known",
      status: purpose.known ? "✅" : "⚠️",
      notes: purpose.notes,
    },
    {
      item: "Likely generated/cache",
      status: generated ? "✅" : "❌",
      notes: generated
        ? "Looks like generated/IDE/build tooling output"
        : "Looks like source/config/manual artifact",
    },
    {
      item: "Tracked by git",
      status: tracked ? "✅" : "❌",
      notes: tracked
        ? "Currently version-controlled"
        : "Not currently version-controlled",
    },
    {
      item: "Ignored by git",
      status: ignored ? "✅" : "❌",
      notes: ignored ? "Matched by .gitignore" : "Not matched by .gitignore",
    },
  ];

  const recommendation = recommend({
    exists,
    generated,
    tracked,
    ignored,
  });

  return {
    targetPath: relativePath,
    rows,
    recommendation,
  };
}

function renderReport(report: NeedItReport): string {
  const header = `Assessment for: \`${report.targetPath}\``;
  const table = [
    "| Item | Status | Notes |",
    "|---|---|---|",
    ...report.rows.map((row) => `| ${row.item} | ${row.status} | ${row.notes} |`),
  ].join("\n");

  return `${header}\n\n${table}\n\nRecoomendation: ${report.recommendation}`;
}

async function pathExists(targetPath: string): Promise<boolean> {
  try {
    await access(targetPath);
    return true;
  } catch {
    return false;
  }
}

function inferPurpose(relativePath: string, isDir: boolean): {
  known: boolean;
  notes: string;
} {
  const normalized = relativePath.replaceAll("\\\\", "/");

  const known: Array<{ match: RegExp; notes: string }> = [
    {
      match: /^\.dart_tool(\/|$)/,
      notes: "Dart/Flutter tooling state and cache",
    },
    {
      match: /^build(\/|$)/,
      notes: "Generated build output",
    },
    {
      match: /^\.idea\/workspace\.xml$/,
      notes: "JetBrains local workspace/session state",
    },
    {
      match: /^node_modules(\/|$)/,
      notes: "Installed dependency cache",
    },
    {
      match: /^\.git(\/|$)/,
      notes: "Git repository metadata",
    },
  ];

  for (const entry of known) {
    if (entry.match.test(normalized)) {
      return { known: true, notes: entry.notes };
    }
  }

  return {
    known: false,
    notes: isDir
      ? "No built-in rule matched; likely project directory"
      : "No built-in rule matched; likely project file",
  };
}

function isGeneratedPath(relativePath: string): boolean {
  const normalized = relativePath.replaceAll("\\\\", "/");
  const generatedPatterns = [
    /^\.dart_tool(\/|$)/,
    /^build(\/|$)/,
    /^\.idea\/workspace\.xml$/,
    /^node_modules(\/|$)/,
    /^dist(\/|$)/,
    /^\.cache(\/|$)/,
  ];
  return generatedPatterns.some((pattern) => pattern.test(normalized));
}

async function isGitTracked(
  exec: ExecFn,
  cwd: string,
  relativePath: string,
): Promise<boolean> {
  const result = await exec(
    "git",
    ["ls-files", "--error-unmatch", "--", relativePath],
    {
      cwd,
    },
  );
  return result.code === 0;
}

async function isGitIgnored(
  exec: ExecFn,
  cwd: string,
  relativePath: string,
): Promise<boolean> {
  const result = await exec("git", ["check-ignore", "-q", "--", relativePath], {
    cwd,
  });
  return result.code === 0;
}

function recommend(args: {
  exists: boolean;
  generated: boolean;
  tracked: boolean;
  ignored: boolean;
}): string {
  if (!args.exists) {
    return "delete it (or update/remove references if it was expected to exist).";
  }

  if (args.generated && args.tracked) {
    return "keep it locally, but stop tracking it in git.";
  }

  if (args.generated && !args.ignored) {
    return "keep it locally and add it to .gitignore.";
  }

  if (args.generated) {
    return "keep it locally; do not commit it.";
  }

  if (!args.tracked && !args.ignored) {
    return "keep it if needed by project logic; commit it if it is source/config.";
  }

  if (args.tracked) {
    return "keep it and commit changes when relevant.";
  }

  return "keep it.";
}
