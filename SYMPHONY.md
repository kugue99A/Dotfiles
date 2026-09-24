# Symphony orchestration for this repository

This repository includes a Symphony workflow contract in `WORKFLOW.md`. Symphony is an external runner: keep the runner checkout and its logs outside this dotfiles repository, and let it clone this repo into per-issue workspaces.

## What this adds

- Linear issues labeled `symphony` can be picked up by the runner.
- Each issue gets an isolated clone under `~/code/symphony-dotfiles-workspaces`.
- Codex runs with `workspace-write` sandboxing and network access for package, GitHub, and Nix checks.
- Real-machine mutation is blocked by prompt policy unless a ticket explicitly says `実機適用可`.

## Prerequisites

- Codex CLI with `codex app-server` available.
- GitHub auth that can clone and push `git@github.com:kugue99A/Dotfiles.git`.
- Linear personal API key exported as `LINEAR_API_KEY`.
- A Linear project for dotfiles work.
- A Linear label named `symphony`.

Symphony is currently preview software intended for trusted environments. Start with low concurrency and review PRs before applying changes to your actual machine.

## One-time setup

1. Copy the slug from the Linear project URL.
2. Replace `REPLACE_WITH_LINEAR_PROJECT_SLUG` in `WORKFLOW.md`.
3. Confirm the Linear workflow has statuses matching `WORKFLOW.md`, or edit the status lists there.
4. Install and build the reference runner outside this repo:

```bash
git clone https://github.com/openai/symphony ~/Workspace/symphony
cd ~/Workspace/symphony/elixir
mise trust
mise install
mise exec -- mix setup
mise exec -- mix build
```

## Run

```bash
export LINEAR_API_KEY="..."
export SYMPHONY_DOTFILES_REPO_URL="git@github.com:kugue99A/Dotfiles.git"

cd ~/Workspace/symphony/elixir
mise exec -- ./bin/symphony \
  /Users/s26988/Workspace/Dotfiles/WORKFLOW.md \
  --logs-root ~/.local/state/symphony-dotfiles/logs \
  --port 4000
```

Then create or move a Linear issue to `Todo` and add the `symphony` label.

## Ticket shape

Good Symphony tickets for this repo should include:

- target config area, for example Neovim, Fish, Home Manager, AeroSpace, or Zellij,
- exact desired behavior,
- acceptance criteria,
- validation commands if you care about specific checks,
- whether real-machine mutation is allowed. Omit this by default.

Use the phrase `実機適用可` only when the agent may run commands such as `home-manager switch`, `./dotfiles apply`, or other commands that affect the current Mac.

## Default safety rules

By default, the workflow tells Codex not to run:

- `./dotfiles apply`
- `./dotfiles destroy`
- `./setup-environment.sh`
- `home-manager switch`
- `darwin-rebuild switch`
- `nix-channel --update`
- `fisher update`
- `nvim +:Lazy sync`

It can still run dry-run and syntax checks such as `./dotfiles plan`, `bash -n`, `nix-instantiate --parse`, `fish -n`, and `luac -p`.

## Useful URLs

- OpenAI article: https://openai.com/ja-JP/index/open-source-codex-orchestration-symphony/
- Symphony repository: https://github.com/openai/symphony
- Reference runner README: https://github.com/openai/symphony/blob/main/elixir/README.md
