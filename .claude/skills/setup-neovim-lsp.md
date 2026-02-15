# Neovim LSP Setup Skill

このスキルは、Neovim 0.10+のネイティブLSP（`vim.lsp.config`と`vim.lsp.enable`）を使用してLanguage Serverをセットアップするためのガイドです。

## 前提条件

- Neovim 0.10以降（`vim.lsp.config`と`vim.lsp.enable`をサポート）
- LSPサーバーがシステムにインストールされていること

## 診断手順

### 1. LSPサーバーのインストール確認

```bash
# TypeScript
which typescript-language-server
which node

# Lua
which lua-language-server

# その他のLSPサーバーも同様に確認
```

### 2. Neovim内でのLSP状態確認

Neovim 0.11では`:LspInfo`コマンドは標準では存在しません。以下の方法で確認：

```vim
" ヘルスチェック（推奨）
:checkhealth vim.lsp

" Luaで直接確認
:lua vim.print(vim.lsp.get_clients())
```

### 3. LSPログの確認

```bash
tail -50 ~/.local/state/nvim/lsp.log
```

エラーの種類：
- `env: node: No such file or directory` → PATH問題
- `Could not find a valid TypeScript installation` → TypeScript未インストールまたはPATH問題
- `exit code 127` → コマンドが見つからない

## 基本的なLSP設定構造

### init.lua

```lua
-- Leader keyを最初に設定
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- バージョンマネージャーのPATH設定（必要に応じて）
-- miseの例：
local function setup_mise_path()
  local mise_bin = vim.fn.expand("~/.local/bin/mise")
  if vim.fn.executable(mise_bin) == 1 then
    local path_additions = {}

    -- Node.js
    local node_path_output = vim.fn.system(mise_bin .. " where node 2>/dev/null")
    if vim.v.shell_error == 0 and node_path_output ~= "" then
      table.insert(path_additions, vim.trim(node_path_output) .. "/bin")
    end

    -- 必要に応じて他のツールも追加

    if #path_additions > 0 then
      vim.env.PATH = table.concat(path_additions, ":") .. ":" .. vim.env.PATH
    end
  end
end

setup_mise_path()

-- コアモジュールの読み込み
require("core.lsp")
```

### lua/core/lsp.lua の基本構造

```lua
-- 診断表示の設定
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
  },
})

-- Capabilitiesの取得
local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end
  return capabilities
end

-- LSPサーバーの設定
vim.lsp.config.SERVER_NAME = {
  cmd = { "server-command", "--stdio" },
  filetypes = { "filetype1", "filetype2" },
  root_markers = { "package.json", ".git" },  -- root_dirではなくroot_markers
  capabilities = get_capabilities(),
  settings = {
    -- サーバー固有の設定
  },
}

-- LSPサーバーの有効化
vim.lsp.enable("SERVER_NAME")
```

## よくある問題と解決方法

### 問題1: `env: node: No such file or directory`

**原因**: NvimからNode.jsが見つからない

**解決方法**:
1. init.luaでPATHを設定
2. バージョンマネージャー（mise、asdf、nodenv等）のbinディレクトリをPATHに追加

```lua
-- miseの例
local node_path = vim.fn.system("mise where node 2>/dev/null")
if vim.v.shell_error == 0 and node_path ~= "" then
  vim.env.PATH = vim.trim(node_path) .. "/bin:" .. vim.env.PATH
end
```

### 問題2: TypeScript LSPが`Could not find a valid TypeScript installation`エラー

**原因**: typescript-language-serverがTypeScriptを見つけられない

**解決方法**:
1. TypeScriptをグローバルまたはプロジェクトにインストール
2. `init_options.tsserver.path`で明示的にパスを指定

```lua
-- lua/lsp/ts_ls.lua
return {
  init_options = (function()
    local init_opts = {
      preferences = {
        -- 設定...
      }
    }

    -- miseからTypeScriptのパスを取得
    local mise_bin = vim.fn.expand("~/.local/bin/mise")
    if vim.fn.executable(mise_bin) == 1 then
      local ts_path = vim.fn.system(mise_bin .. " where npm:typescript 2>/dev/null")
      if vim.v.shell_error == 0 and ts_path ~= "" then
        init_opts.tsserver = {
          path = vim.trim(ts_path) .. "/lib/node_modules/typescript/lib"
        }
      end
    end

    return init_opts
  end)(),
}
```

### 問題3: LSPが起動しない（一般）

**確認事項**:
1. LSPサーバーがインストールされているか: `which <server-command>`
2. `vim.lsp.enable()`を呼んでいるか
3. `root_markers`に一致するファイルがプロジェクトにあるか
4. filetypeが正しいか: `:set filetype?`

### 問題4: `:LspInfo`コマンドが存在しない

**原因**: Neovim 0.11のネイティブLSPには`:LspInfo`は含まれていない（nvim-lspconfigプラグインのコマンド）

**解決方法**: カスタムコマンドを追加

```lua
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.INFO)
    return
  end

  local lines = { "LSP Clients:", "" }
  for _, client in ipairs(clients) do
    table.insert(lines, string.format("• %s (id: %d)", client.name, client.id))
    table.insert(lines, string.format("  - root_dir: %s", client.config.root_dir or "N/A"))
    table.insert(lines, string.format("  - initialized: %s", client.initialized))
    table.insert(lines, "")
  end

  -- フローティングウィンドウで表示
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 80,
    height = math.min(#lines, 20),
    col = (vim.o.columns - 80) / 2,
    row = (vim.o.lines - math.min(#lines, 20)) / 2,
    style = "minimal",
    border = "rounded",
    title = " LSP Info ",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
end, { desc = "Show LSP info" })
```

## LSPサーバー別の設定例

### TypeScript/JavaScript (ts_ls)

```lua
vim.lsp.config.ts_ls = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  capabilities = get_capabilities(),
}
vim.lsp.enable("ts_ls")
```

### Lua (lua_ls)

```lua
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  capabilities = get_capabilities(),
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
vim.lsp.enable("lua_ls")
```

### Python (pyright)

```lua
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  capabilities = get_capabilities(),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
}
vim.lsp.enable("pyright")
```

### Go (gopls)

```lua
vim.lsp.config.gopls = {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = get_capabilities(),
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
    },
  },
}
vim.lsp.enable("gopls")
```

### Rust (rust_analyzer)

```lua
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
  capabilities = get_capabilities(),
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      check = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
}
vim.lsp.enable("rust_analyzer")
```

## モジュラー構成の推奨方法

### ディレクトリ構造

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   └── lsp.lua          # メインLSP設定
    └── lsp/
        ├── ts_ls.lua        # TypeScript LSP固有設定
        ├── lua_ls.lua       # Lua LSP固有設定
        └── rust_analyzer.lua # Rust LSP固有設定
```

### lua/core/lsp.lua でカスタム設定を読み込む

```lua
-- サーバー固有の設定を読み込む関数
local function load_server_config(server_name)
  local config_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "lsp", server_name .. ".lua")

  if vim.uv.fs_stat(config_path) then
    local ok, custom_config = pcall(dofile, config_path)
    if ok and type(custom_config) == "table" then
      return custom_config
    end
  end
  return {}
end

-- 使用例
local ts_custom = load_server_config("ts_ls")
vim.lsp.config.ts_ls = vim.tbl_deep_extend("force", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", ".git" },
  capabilities = get_capabilities(),
}, ts_custom)

vim.lsp.enable("ts_ls")
```

## バージョンマネージャー統合

### mise

```lua
local function setup_mise_path()
  local mise_bin = vim.fn.expand("~/.local/bin/mise")
  if vim.fn.executable(mise_bin) == 1 then
    local path_additions = {}

    -- 必要なツールのパスを追加
    for _, tool in ipairs({ "node", "npm:typescript-language-server" }) do
      local output = vim.fn.system(mise_bin .. " where " .. tool .. " 2>/dev/null")
      if vim.v.shell_error == 0 and output ~= "" then
        table.insert(path_additions, vim.trim(output) .. "/bin")
      end
    end

    if #path_additions > 0 then
      vim.env.PATH = table.concat(path_additions, ":") .. ":" .. vim.env.PATH
    end
  end
end
```

### asdf

```lua
local function setup_asdf_path()
  local asdf_dir = vim.fn.expand("~/.asdf")
  if vim.fn.isdirectory(asdf_dir) == 1 then
    local nodejs_version = vim.fn.system("asdf current nodejs 2>/dev/null | awk '{print $2}'")
    if vim.v.shell_error == 0 and nodejs_version ~= "" then
      local node_bin = asdf_dir .. "/installs/nodejs/" .. vim.trim(nodejs_version) .. "/bin"
      vim.env.PATH = node_bin .. ":" .. vim.env.PATH
    end
  end
end
```

## デバッグ方法

### LSPログの有効化

```lua
-- より詳細なログが必要な場合
vim.lsp.set_log_level("debug")  -- "trace", "debug", "info", "warn", "error"
```

ログファイル: `~/.local/state/nvim/lsp.log`

### 手動でLSPクライアントを起動

```lua
:lua vim.lsp.enable("ts_ls")  -- 手動で有効化
:lua vim.print(vim.lsp.get_clients())  -- クライアント一覧
```

### PATHの確認

```lua
:lua vim.print(vim.env.PATH)
```

## チェックリスト

LSPが動作しない場合、以下を順番に確認：

- [ ] LSPサーバーがインストールされているか（`which <command>`）
- [ ] Neovimのバージョンが0.10以降か（`:version`）
- [ ] `vim.lsp.config.<server>`で設定を定義したか
- [ ] `vim.lsp.enable("<server>")`を呼んだか
- [ ] filetypeが正しいか（`:set filetype?`）
- [ ] root_markersに一致するファイルがプロジェクトにあるか
- [ ] PATHにLSPサーバーのディレクトリが含まれているか（`:lua vim.print(vim.env.PATH)`）
- [ ] LSPログにエラーがないか（`~/.local/state/nvim/lsp.log`）

## 参考資料

- Neovim LSP公式ドキュメント: `:help lsp`
- LSPクイックスタート: `:help lsp-quickstart`
- vim.lsp.config: `:help vim.lsp.config`
- vim.lsp.enable: `:help vim.lsp.enable`
- checkhealth: `:checkhealth vim.lsp`
