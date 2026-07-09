#!/usr/bin/env bash

set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
	echo "codex is required" >&2
	exit 1
fi

if ! command -v bunx >/dev/null 2>&1; then
	echo "bunx is required" >&2
	exit 1
fi

if codex mcp get chrome-devtools >/dev/null 2>&1; then
	echo "Chrome DevTools MCP is already registered."
else
	codex mcp add chrome-devtools -- bunx chrome-devtools-mcp@latest --autoConnect
	echo "Chrome DevTools MCP registered."
fi

if codex mcp get playwright >/dev/null 2>&1; then
	echo "Playwright MCP is already registered."
else
	codex mcp add playwright -- bunx @playwright/mcp@latest --browser=chrome
	echo "Playwright MCP registered."
fi

echo "Start a new Codex CLI session to use newly registered MCP servers."
