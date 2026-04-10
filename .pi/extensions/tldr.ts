import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function tldrExtension(pi: ExtensionAPI) {
  let lastAssistantText = "";

  pi.on("message_end", async (event) => {
    const message = (event as { message?: unknown }).message;
    const extracted = extractAssistantText(message);
    if (extracted) {
      lastAssistantText = extracted;
    }
  });

  pi.registerCommand("tldr", {
    description:
      "Create a short TL;DR from the last assistant message and send it to do-i-need-it external content.",
    handler: async (args, ctx) => {
      const input = args?.trim();
      const sourceText = input && input.length > 0 ? input : lastAssistantText;
      if (!sourceText) {
        ctx.ui.notify("No assistant text found yet for TL;DR", "info");
        return;
      }

      const summary = buildTldr(sourceText);
      pi.events.emit("do-i-need-it:content", {
        source: "tldr",
        content: summary,
      });

      ctx.ui.notify("TL;DR captured for do-i-need-it", "success");
      pi.sendMessage({
        customType: "tldr",
        content: `TL;DR: ${summary}`,
        display: true,
      });
    },
  });
}

function extractAssistantText(message: unknown): string {
  if (!message || typeof message !== "object") {
    return "";
  }

  const role = (message as { role?: unknown }).role;
  if (role !== "assistant") {
    return "";
  }

  const content = (message as { content?: unknown }).content;

  if (typeof content === "string") {
    return content.trim();
  }

  if (!Array.isArray(content)) {
    return "";
  }

  const chunks = content
    .map((item) => {
      if (!item || typeof item !== "object") {
        return "";
      }
      const text = (item as { text?: unknown }).text;
      return typeof text === "string" ? text : "";
    })
    .filter((text) => text.length > 0);

  return chunks.join(" ").trim();
}

function buildTldr(text: string): string {
  const normalized = text.replace(/\s+/g, " ").trim();
  if (normalized.length <= 220) {
    return normalized;
  }
  return `${normalized.slice(0, 217)}...`;
}
