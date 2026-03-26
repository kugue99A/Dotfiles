# 起動速度最適化レポート

**日付**: 2026-02-27
**環境**: macOS Darwin 25.2.0 / Fish 4.3.3 / Neovim 0.11.6

---

## 結果サマリー

| 対象 | Before | After | 改善率 | 倍速 |
|------|--------|-------|--------|------|
| Fish Shell | 968.0ms ± 60.5ms | 179.9ms ± 11.6ms | **-81.4%** | **5.4x** |
| Neovim | 99.2ms ± 5.6ms | 51.1ms ± 4.0ms | **-48.5%** | **1.9x** |

---

## Fish Shell 分析

### Before: ボトルネック Top 5

| # | 項目 | 時間 | 割合 |
|---|------|------|------|
| 1 | `colima status` | 795ms | 82.1% |
| 2 | `mise hook-env` | 132ms | 13.6% |
| 3 | `starship init` | 36ms | 3.7% |
| 4 | `zoxide init` | 7ms | 0.7% |
| 5 | その他 | ~2ms | - |

### 改善内容

#### `colima.fish` — `colima status` → ソケットファイル判定 (-795ms)

**問題**: `colima status` コマンドはColima VMの状態を問い合わせるため ~800ms かかる。これがシェル起動のたびに実行されていた。

**解決**: `~/.colima/default/docker.sock` のソケットファイル存在チェックに変更。ファイルシステム操作のため ~0ms。

```fish
# Before (795ms)
if not colima status >/dev/null 2>&1

# After (~0ms)
if not test -S "$HOME/.colima/default/docker.sock"
```

### After: ボトルネック Top 5

| # | 項目 | 時間 | 備考 |
|---|------|------|------|
| 1 | `mise hook-env` | 117ms | mise固有のオーバーヘッド（最適化困難） |
| 2 | `starship init` | 23ms | 正常範囲 |
| 3 | `zoxide init` | 8ms | 正常範囲 |
| 4 | `fish_config theme` | 5ms | 正常範囲 |

### hyperfine 詳細

```
# Before
Time (mean ± σ):     968.0 ms ±  60.5 ms
Range (min … max):   901.3 ms … 1090.1 ms    10 runs

# After
Time (mean ± σ):     179.9 ms ±  11.6 ms
Range (min … max):   166.0 ms … 194.2 ms    10 runs
```

---

## Neovim 分析

### Before: 起動タイムライン (主要項目)

| # | 項目 | 時間 | 備考 |
|---|------|------|------|
| 1 | `init.lua` (total) | 96ms | setup_mise_path + lazy + core modules |
| 2 | `setup_mise_path()` | ~60ms | `vim.fn.system()` x2 (同期外部コマンド) |
| 3 | `config.lazy` | 25ms | lazy.nvim初期化 |
| 4 | `core.lsp` | 6.3ms | cmp_nvim_lsp即時ロード含む |
| 5 | `tokyonight` | 4.5ms | カラースキーム読み込み |
| 6 | `cmp_nvim_lsp` | 1.8ms | 起動時にrequire |

### 改善内容

#### 1. `setup_mise_path()` の遅延実行 (-60ms)

**問題**: `vim.fn.system("mise where node")` と `vim.fn.system("mise where npm:typescript-language-server")` を起動時に同期実行。各 ~30ms。

**解決**: `User VeryLazy` イベントに遅延。LSP起動前に実行されるため機能への影響なし。

```lua
-- Before: 起動時に同期実行 (~60ms)
setup_mise_path()

-- After: VeryLazy イベントで遅延実行 (起動時 0ms)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function() ... end,
})
```

#### 2. `cmp_nvim_lsp` の遅延ロード (-1.8ms)

**問題**: `get_capabilities()` が起動時に `require("cmp_nvim_lsp")` を呼び出し、cmpモジュール群を即座にロード。

**解決**: `vim.lsp.config("*")` では基本 capabilities のみ設定し、`LspAttach` で cmp capabilities をマージ。

### After: 起動タイムライン (主要項目)

| # | 項目 | 時間 | 備考 |
|---|------|------|------|
| 1 | `init.lua` (total) | 14ms | mise path除外で大幅短縮 |
| 2 | `config.lazy` | 10ms | lazy.nvim初期化 |
| 3 | `core.lsp` | 2.1ms | cmp_nvim_lsp除外 |
| 4 | ShaDa reading | 1.0ms | 固定コスト |

### hyperfine 詳細

```
# Before
Time (mean ± σ):      99.2 ms ±   5.6 ms
Range (min … max):    87.6 ms … 105.9 ms    10 runs

# After
Time (mean ± σ):      51.1 ms ±   4.0 ms
Range (min … max):    46.1 ms … 57.3 ms    10 runs
```

---

## 変更ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `macos/.config/fish/conf.d/colima.fish` | `colima status` → ソケットファイル判定 |
| `macos/.config/nvim/init.lua` | `setup_mise_path()` を VeryLazy に遅延 |
| `macos/.config/nvim/lua/core/lsp.lua` | `cmp_nvim_lsp` を LspAttach 時にロード |

## 今後の改善候補

| 項目 | 現在の時間 | 難易度 | 備考 |
|------|-----------|--------|------|
| `mise hook-env` | 117ms | 高 | mise固有。`--quiet` オプションや mise shims への移行が候補 |
| `starship init` | 23ms | 中 | starship のモジュール削減で多少改善可能 |
| ShaDa reading | 1.0ms | - | Neovim固有の固定コスト、最適化不要 |
