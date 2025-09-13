-- Modern LSP configuration using vim.lsp.config and vim.lsp.enable
local M = {}

-- Configure diagnostic display
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
    header = "",
    prefix = "",
  },
})

-- Configure diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Get nvim-cmp capabilities if available
local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end
  return capabilities
end

-- Function to safely load server-specific config
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

-- Configure LSP servers using vim.lsp.config
-- Lua Language Server
local lua_custom = load_server_config("lua_ls")
vim.lsp.config.lua_ls = vim.tbl_deep_extend("force", {
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
      completion = { callSnippet = "Replace" },
      diagnostics = { 
        globals = { "vim" },
        disable = { "missing-fields" } 
      },
    },
  },
}, lua_custom)

-- TypeScript Language Server
local ts_custom = load_server_config("ts_ls")
vim.lsp.config.ts_ls = vim.tbl_deep_extend("force", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", ".git" },
  capabilities = get_capabilities(),
}, ts_custom)

-- HTML Language Server
local html_custom = load_server_config("html")
vim.lsp.config.html = vim.tbl_deep_extend("force", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "templ" },
  root_markers = { "package.json", ".git", "index.html" },
  capabilities = get_capabilities(),
  init_options = {
    provideFormatter = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { "html", "css", "javascript" },
  },
}, html_custom)

-- CSS Language Server
vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
  capabilities = get_capabilities(),
  settings = {
    css = { validate = true },
    less = { validate = true },
    scss = { validate = true },
  },
}

-- Go Language Server
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
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

-- Rust Analyzer
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },
  capabilities = get_capabilities(),
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
}

-- Python Language Server
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
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

-- Deno Language Server (only when deno.json exists)
vim.lsp.config.denols = {
  cmd = { "deno", "lsp" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "deno.json", "deno.jsonc" },
  capabilities = get_capabilities(),
}

-- Enable LSP servers
local servers_to_enable = {
  "lua_ls",
  "ts_ls", 
  "html",
  "cssls",
  "gopls",
  "rust_analyzer", 
  "pyright",
  "denols"
}

for _, server in ipairs(servers_to_enable) do
  vim.lsp.enable(server)
end

-- Configure LSP handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  title = "Hover",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  title = "Signature Help",
})

return M