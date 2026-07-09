---
name: playwright-ui-loop
description: Run repeatable UI improvement and browser-debugging loops from Codex CLI with Chrome DevTools MCP for live-browser diagnosis and Playwright MCP or project-local Playwright for reproducible verification. Use when asked to reproduce or fix visual regressions, inspect live DOM or computed styles, compare screenshots, investigate responsive layout or accessibility, capture console/network evidence, verify a local web app, or turn a discovered UI bug into a durable Playwright regression test.
---

# Playwright UI Loop

Use browser evidence to drive the loop: reproduce, measure, change, and verify.

## Select the browser path

1. Prefer Chrome DevTools MCP with `--autoConnect` when diagnosis depends on the user's open, authenticated Chrome tab.
2. Prefer Playwright MCP for interactive work in a dedicated browser profile and project-local Playwright for durable regression tests.
3. Otherwise use the repository's installed Playwright package and its package manager.
4. Prefer a dedicated persistent Playwright profile for authenticated automation that does not require the user's live tab.
5. Use `storageState` for repeatable test authentication. Keep auth artifacts ignored by Git.
6. Do not attach to, terminate, relaunch, or copy a user's normal browser profile without explicit permission.
7. Do not install dependencies when the repository already provides Playwright or when project rules prohibit it.

Read [references/setup-and-evidence.md](references/setup-and-evidence.md) when MCP setup, authentication, CDP, trace capture, or evidence format matters. When either browser MCP is missing on this machine, run `scripts/setup-browser-mcps.sh` only after confirming the user wants a user-scoped Codex configuration change.

## Run the loop

### 1. Establish constraints

- Read repository instructions before running commands or editing files.
- Identify the target URL, viewport, expected behavior, and reference branch/design.
- Preserve unrelated worktree changes.
- Determine whether authentication is required before choosing the browser path.

### 2. Capture the baseline

Before editing, collect evidence proportional to the issue:

- viewport and device pixel ratio;
- screenshot of the affected region and, when useful, the full page;
- relevant DOM ancestry;
- bounding rectangles for the target, containing block, and neighboring elements;
- computed layout properties such as `display`, `position`, `width`, `height`, `min-*`, `max-*`, `overflow`, `aspect-ratio`, grid placement, and object fitting;
- browser console errors and failed/relevant network requests;
- accessibility roles/names for interactive UI.

Report exact measured values. Do not infer dimensions only from a screenshot.

### 3. Form and test one hypothesis

- Compare the measured DOM/CSS contract with the implementation and reference state.
- Identify the first element whose computed box violates its parent contract.
- Change the smallest responsible layer.
- Preserve unrelated layout, color, copy, interaction, and accessibility behavior.
- Keep duplicated implementations synchronized only when repository architecture requires it.

### 4. Verify in the browser

Repeat the same viewport, state, selectors, measurements, and screenshots after the change.

Require all applicable checks:

- target rectangle stays within its intended containing rectangle;
- neighboring elements do not overlap unexpectedly;
- intended responsive variants still work;
- console and network have no new failures;
- accessible name, role, focus behavior, and keyboard interaction remain valid;
- visual comparison shows only the intended change.

### 5. Convert the bug into a regression check

Prefer structural assertions before screenshot assertions:

- assert bounding-box containment or expected grid placement;
- assert visibility, role, accessible name, and state;
- add a focused screenshot assertion when pixels are part of the contract;
- retain a trace on failure for DOM, console, and network inspection.

Use resilient locators in this order: role/label/text, stable test contract, then narrowly scoped CSS. Avoid selectors coupled to generated class names.

### 6. Run project quality gates

- Run the targeted Playwright test first.
- Run repository-required checks and related unit/component tests.
- State exact commands, passes, failures, and skipped checks.

## Deliver the result

Summarize:

- root cause with measured before/after values;
- minimal files changed;
- browser evidence and artifact paths;
- regression coverage and quality-check results;
- remaining limitations, especially authentication or browser-connection constraints.
