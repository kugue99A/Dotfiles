# Terminal and CLI color customization

Last updated: 2026-10-26

This note records which layer owns each color and what can be changed in this
repository. It is intended to prevent terminal palette changes from being
mistaken for application theme settings.

## Current ownership

| Surface | Source of colors | Local setting |
| --- | --- | --- |
| WezTerm text, ANSI palette, and terminal background | WezTerm color scheme | `macos/.config/wezterm/wezterm.lua` |
| WezTerm block cursor and IME composition cursor | WezTerm `cursor_*` and `compose_cursor` colors | `macos/.config/wezterm/wezterm.lua` |
| Codex CLI syntax highlighting | Codex `tui.theme` TextMate theme | `macos/.config/home-manager/themes/ashes-light.tmTheme` and `~/.codex/config.toml` |
| Neovim light theme | Local Ashes Light colorscheme, selected by the shared `theme light` state | `macos/.config/nvim/colors/ashes-light.lua` and `macos/.config/nvim/lua/core/theme.lua` |
| Codex CLI composer fill and accent | Codex TUI derives colors from terminal-reported background and color depth; WezTerm indexed palette can change the resulting ANSI-256 colors | `macos/.config/wezterm/wezterm.lua` |
| Herdr panels and rows | Herdr's own theme config; `name = "terminal"` follows terminal colors where supported, with custom values overriding named palette roles | `macos/.config/home-manager/herdr.nix` |
| Claude Code CLI | Claude Code TUI theme/config, separate from Herdr and WezTerm | `~/.claude/settings.json` (managed/user config; inspect before editing) |
| LazyGit panels and rows | LazyGit `gui.theme` and `gui.colorScheme` | `macos/.config/lazygit/config.yml` |
| Git diff additions shown by LazyGit's `rawGit` renderer | Git diff ANSI colors, rendered through WezTerm's ANSI palette | `macos/.config/wezterm/wezterm.lua` (`Ashes Light` ANSI green) |
| SketchyBar labels, widgets, and focused workspace | SketchyBar config plus the shared `theme` state; workspace updates come from its status daemon | `macos/.config/home-manager/sketchybar.nix` and `macos/.config/home-manager/sketchybar/status_daemon.py` |
| macOS IME preedit/candidate UI | Input method and terminal rendering path | Not reliably controlled by a Codex TextMate theme |

## Codex and the composer

Codex has more than one color path:

1. `tui.theme` selects syntax highlighting. It does not set every TUI color.
2. Codex derives some UI accents from the detected terminal background. With
   `FORCE_COLOR=2`, Codex uses ANSI-256 colors for those accents; its light
   background accent can resolve to indexed color 75, which is vivid blue in
   the stock xterm-256 palette.
3. Composer shading is also derived by Codex from the probed terminal colors.
   In this setup, the composer fill resolves to indexed color 237. We override
   that one slot to keep the composer near-white without changing the terminal
   default/window background.
4. Other indexed colors can affect accent or status colors. The Ashes Light
   override currently softens indexes 46, 75, and 81 in addition to composer
   fill 237. Submitted prompt cards are blended from the detected terminal
   background too; with ANSI-256 output the dark-background shade maps to
   indexed gray 238. Light mode maps that slot to a pale Ashes surface. These
   are terminal palette adjustments, not Codex theme tokens.

The block cursor has independent `cursor_bg`, `cursor_fg`, and
`cursor_border` colors. While an IME/dead-key composition is pending, WezTerm
can use `compose_cursor` instead. Both are explicitly set to a muted Ashes
blue-gray in light mode so the cursor does not inherit vivid green.

The overrides live in `wezterm.lua` under `ashes_light_scheme.indexed`. The
window background remains `Tokyo Night`'s configured background in light mode;
opacity and blur are separate WezTerm settings.

The installed Codex theme file provides syntax colors and a muted `codex.accent`
scope. `~/.codex/config.toml` selects it with `theme = "ashes-light"`. A theme
change or environment wrapper affects newly launched Codex processes; an
already-running TUI retains its startup palette.

## Japanese IME color limits

WezTerm has a separate `compose_cursor` specifically for pending IME/dead-key
composition. If green remains after the light config is reloaded, inspect the
cursor during ordinary typing and during Japanese composition separately. A
green block only during composition points to the composition cursor path; a
green fill during ordinary typing points to an application escape sequence
overriding the terminal cursor color.

## Herdr active and inactive rows

Herdr 0.9.5 uses `theme.custom.accent` for the active tab fill and
`theme.custom.active_row_bg` for active Space and focused Agent rows. The tab
foreground is derived from `panel_bg` (or `surface_dim` when the panel
background is reset), while row labels use palette text and per-token styles.
This version does not expose independent active-tab foreground/background
tokens, so use a light active fill with dark text for a consistent combination.

Inactive branch, provider, quota, and context fields should not rely on the
terminal theme's default overlay colors or dim modifier. Define `overlay0`,
`overlay1`, and `subtext0`, then use inline token styles with `dim = false` for
the fields whose dim rendering has poor contrast on a translucent desktop.
Herdr supports config validation with `herdr config check` and live server
reloading with `herdr server reload-config`.

## Neovim

The shared Fish `theme light` command sets `~/.local/state/dotfiles/theme`.
Neovim reads that file at startup and watches for changes. In light mode it now
loads the local `ashes-light` colorscheme using the Ashes Light terminal
background, foreground, ANSI palette, and matching syntax/UI accents. Dark mode
continues to use Tokyo Night. Core plugin highlights select colors from the
active colorscheme so Tokyo Night values do not leak into the Ashes setup.

Avoid changing the terminal background to fix a composer-only contrast issue:
Codex's background probe and WezTerm's translucent window background are
separate concerns.

## LazyGit and Git diff colors

LazyGit uses `gui.colorScheme` to select light or dark UI defaults, and
`gui.theme` to override panel borders, selected rows, and text. These settings
do not recolor Git's raw diff output. This setup uses the `rawGit` diff renderer,
so added and removed lines use Git's `color.diff.new` / `color.diff.old` ANSI
colors and are then mapped by the terminal palette. Ashes Light's stock green
is pastel; over a bright desktop seen through the translucent terminal it can
look washed out. The light palette therefore keeps the Ashes green hue while
using a darker ANSI green (`#52735F`) and bright green (`#6C8D77`).

The tracked LazyGit config is not Home Manager managed. In this setup,
`macos/.config/lazygit/config.yml` and `~/.config/lazygit/config.yml` are hard
links to the same file, so repository edits take effect at LazyGit's config path
without `home-manager switch` or `./dotfiles apply`. Restart LazyGit to load
theme changes. This is separate from the WezTerm config reload.

References:

- [LazyGit configuration reference](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) — `gui.colorScheme`, theme fields, and `git.diffRenderers`.
- [LazyGit custom diff renderers](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_DiffRenderers.md) — `rawGit` delegates diff output to Git, while stdin filters can use a pager.
- [Git color configuration](https://git-scm.com/docs/git-config#Documentation/git-config.txt-color) — Git's diff colors are separate from LazyGit's panel theme.

## SketchyBar

SketchyBar uses Ashes Light colors when the shared `~/.local/state/dotfiles/theme`
state is `light`, and retains its existing Iceberg palette in `dark` mode. The
main bar config reads that state on `sketchybar --reload`; the status daemon
reads it on its five-second refresh and colors the focused workspace with one
consistent muted lavender fill. The Fish `theme` command reloads SketchyBar
after changing the shared state.

Workspace background color, height, and corner radius are static item settings.
The status daemon updates app labels and foreground colors during its regular
refresh. It sends background drawing changes only for workspace focus states
that changed, with the new focused workspace enabled before the previous one is
disabled. Reapplying background dimensions and colors on every refresh can
briefly turn each workspace background on in sequence. Display assignment is
sent only when it changes, before focus-state changes. Inactive app icons use
the Ashes foreground text color so they remain visible over the desktop. After
changing the daemon source, run Home Manager switch to restart the managed
SketchyBar status agent.

References:

- [SketchyBar configuration reload](https://felixkratz.github.io/SketchyBar/config/reloading) — `sketchybar --reload` re-reads the active config.
- [Codex TUI style implementation](https://github.com/openai/codex/blob/main/codex-rs/tui/src/style.rs) — submitted prompt and history surfaces are blended from the detected terminal background.
- [Codex terminal palette implementation](https://github.com/openai/codex/blob/main/codex-rs/tui/src/terminal_palette.rs) — maps blended RGB colors to indexed xterm colors when ANSI-256 is active.

## Applying changes

After editing these Home Manager sources, activate them with:

```sh
home-manager -f ~/.config/home-manager/home.nix switch
```

WezTerm watches its config and normally reloads it automatically; on macOS,
`Cmd+Shift+R` forces a reload. Start a fresh Codex CLI process so it re-reads
the terminal palette. Check `~/.codex/config.toml` for
`theme = "ashes-light"` and confirm that the shell resolves `codex` through the
repository's Fish function if the `FORCE_COLOR=2` palette behavior is needed.

## References

- [Codex configuration reference](https://developers.openai.com/codex/config-reference/) — `tui.theme` is documented as a syntax-highlighting override.
- [Codex TUI style implementation](https://github.com/openai/codex/blob/main/codex-rs/tui/src/style.rs) — derives accents from terminal background and color depth.
- [Codex terminal palette implementation](https://github.com/openai/codex/blob/main/codex-rs/tui/src/terminal_palette.rs) — probes terminal default colors and resolves indexed colors.
- [WezTerm colors & appearance](https://wezterm.org/config/appearance.html) — terminal palette, cursor colors, and composition cursor colors.
- [WezTerm configuration files](https://wezterm.org/config/files.html) — automatic config reload and the manual reload shortcut.
- [WezTerm Ashes Light scheme](https://wezterm.org/colorschemes/a/index.html) — upstream Ashes Light color scheme.
- [Herdr config reference](https://herdr.dev/docs/config-reference/) — documents theme tokens, active row background, and inline sidebar token styles.
- [Herdr theme implementation](https://github.com/herdrdev/herdr/blob/master/src/app/state.rs) — maps palette tokens used by the UI.
