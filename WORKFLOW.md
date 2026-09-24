---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  # Replace this with the slug copied from the Linear project URL.
  project_slug: "REPLACE_WITH_LINEAR_PROJECT_SLUG"
  required_labels:
    - symphony
  active_states:
    - Todo
    - In Progress
    - Rework
    - Merging
  terminal_states:
    - Done
    - Closed
    - Cancelled
    - Canceled
    - Duplicate
polling:
  interval_ms: 10000
workspace:
  root: ~/code/symphony-dotfiles-workspaces
hooks:
  after_create: |
    : "${SYMPHONY_DOTFILES_REPO_URL:=git@github.com:kugue99A/Dotfiles.git}"
    git clone --depth 1 "$SYMPHONY_DOTFILES_REPO_URL" .
    git fetch origin
    if [ -f macos/.config/home-manager/local.nix.example ] && [ ! -f macos/.config/home-manager/local.nix ]; then
      cp macos/.config/home-manager/local.nix.example macos/.config/home-manager/local.nix
    fi
    chmod +x ./dotfiles ./setup-environment.sh
agent:
  max_concurrent_agents: 2
  max_turns: 12
codex:
  command: codex --config shell_environment_policy.inherit=all app-server
  approval_policy: never
  thread_sandbox: workspace-write
  turn_sandbox_policy:
    type: workspaceWrite
    networkAccess: true
---

You are working on this Dotfiles repository through Symphony for Linear issue `{{ issue.identifier }}`.

回答、Linear コメント、PR 説明は原則として日本語で書くこと。引用が必要なコマンド名、ファイル名、エラーは原文のまま残すこと。

{% if attempt %}
Continuation context:

- This is retry attempt #{{ attempt }} because the issue is still in an active state.
- Resume from the current workspace state instead of restarting from scratch.
- Do not repeat already-completed investigation or validation unless needed for new changes.
{% endif %}

Issue context:

- Identifier: `{{ issue.identifier }}`
- Title: `{{ issue.title }}`
- Current status: `{{ issue.state }}`
- Labels: `{{ issue.labels }}`
- URL: `{{ issue.url }}`

Description:

{% if issue.description %}
{{ issue.description }}
{% else %}
No description provided.
{% endif %}

## Operating posture

1. Work only inside the Symphony-created repository copy.
2. Treat this as a personal macOS dotfiles repo. Prefer small, reversible changes.
3. Do not run commands that mutate the operator's real machine unless the issue explicitly says `実機適用可`.
4. Never run these commands by default: `./dotfiles apply`, `./dotfiles destroy`, `./setup-environment.sh`, `home-manager switch`, `darwin-rebuild switch`, `nix-channel --update`, `fisher update`, or `nvim +:Lazy sync`.
5. Dry-run, syntax-check, build, and parse commands are allowed when scoped to the workspace.
6. Preserve unrelated worktree changes. Do not use destructive git commands such as `git reset --hard` or `git checkout -- .`.
7. Keep secrets out of the repository. Do not commit `.env`, tokens, `local.nix`, logs, caches, or machine-specific generated state.

## State flow

- `Backlog`: out of scope for Symphony. Do not modify.
- `Todo`: move to `In Progress`, create or update the workpad, then start.
- `In Progress`: continue from the workpad and current workspace state.
- `Human Review`: wait for reviewer feedback or approval.
- `Rework`: re-read the issue and review feedback, update the plan, then address requested changes.
- `Merging`: merge only after human approval and green validation.
- Terminal states: no further work.

If Linear tools are unavailable, record the blocker in the final response and stop. If available, maintain one persistent Linear comment headed `## Codex Workpad` and update it instead of creating separate progress comments.

## Execution checklist

1. Read the issue body, comments, acceptance criteria, and attached PRs.
2. Inspect repository state with `git status --short`, `git branch --show-current`, and `git rev-parse --short HEAD`.
3. Sync with `origin/main` before editing unless the issue explicitly targets another branch.
4. Create a topic branch named `symphony/<issue-identifier>-<short-slug>`.
5. Write or update the workpad with:
   - concise plan,
   - acceptance criteria,
   - validation plan,
   - current branch and short SHA,
   - blockers or assumptions.
6. Reproduce or inspect the current behavior before changing files.
7. Implement the smallest change that satisfies the issue.
8. Run targeted validation and record exact command outcomes.
9. Commit logical changes, push the branch, and open a draft PR when code or docs changed.
10. Before moving to `Human Review`, confirm validation passed and there is no unresolved actionable PR feedback.

## Repository-specific guidance

This repository combines:

- manual symlink management via `./dotfiles`,
- Nix/Home Manager configuration under `macos/.config/home-manager`,
- nix-darwin configuration under `macos/.config/nix-darwin`,
- Neovim configuration under `macos/.config/nvim`,
- shell/runtime tooling through Fish and Mise.

Follow the existing layout. Put new user config under `macos/.config/<tool>/` unless the change belongs in Home Manager. Add packages to the appropriate Nix file instead of installing them imperatively.

Important local conventions:

- Fish functions are managed by Home Manager, not by direct files under `macos/.config/fish/functions`.
- `macos/.config/home-manager/local.nix` is machine-specific and must not be committed.
- `.dotfiles_state` is generated state. Do not update it intentionally as part of Symphony work.
- Keep the visual theme consistent with the repository's current terminal/editor theme choices unless the issue asks for a theme migration.

## Validation matrix

Always run these when relevant:

```bash
bash -n dotfiles setup-environment.sh
./dotfiles plan
```

For Nix/Home Manager changes:

```bash
find macos/.config/home-manager -name '*.nix' -print0 | xargs -0 -n1 nix-instantiate --parse >/dev/null
```

For nix-darwin changes:

```bash
nix flake check macos/.config/nix-darwin
```

For Fish changes:

```bash
find macos/.config/fish -name '*.fish' -print0 | xargs -0 -n1 fish -n
```

For Neovim Lua changes:

```bash
find macos/.config/nvim -name '*.lua' -print0 | xargs -0 -n1 luac -p
```

If a validator is unavailable in the workspace, record `not run` with the missing command and choose the closest low-risk check.

## Handoff

The final Linear workpad update and PR description must include:

- summary of changed files,
- validation commands and outcomes,
- any skipped validation and why,
- any manual follow-up required before applying dotfiles to the real machine.

Do not claim the dotfiles were applied to the operator's machine unless the issue explicitly allowed real-machine mutation and the command actually succeeded.
