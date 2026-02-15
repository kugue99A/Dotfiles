-- Modern LSP configuration using vim.lsp.config and vim.lsp.enable (Neovim 0.11+)
-- LSP server configurations are in nvim/lsp/*.lua (auto-loaded by Neovim)
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

-- Configure common settings for all LSP servers
vim.lsp.config("*", {
  capabilities = get_capabilities(),
  root_markers = { ".git" },
})

-- LspAttach autocmd for common setup (on_attach replacement in Neovim 0.11+)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Enable inlay hints if available
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- Server-specific configurations
    if client then
      -- Lua: Disable formatting (use stylua instead)
      if client.name == "lua_ls" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      -- TypeScript: Disable formatting (use prettier instead) and add commands
      if client.name == "ts_ls" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- TypeScript-specific commands
        vim.api.nvim_buf_create_user_command(bufnr, "TypescriptOrganizeImports", function()
          vim.lsp.buf.execute_command({
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
          })
        end, { desc = "Organize imports" })

        vim.api.nvim_buf_create_user_command(bufnr, "TypescriptAddMissingImports", function()
          vim.lsp.buf.execute_command({
            command = "_typescript.addMissingImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
          })
        end, { desc = "Add missing imports" })

        vim.api.nvim_buf_create_user_command(bufnr, "TypescriptRemoveUnusedImports", function()
          vim.lsp.buf.execute_command({
            command = "_typescript.removeUnusedImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
          })
        end, { desc = "Remove unused imports" })
      end

      -- Rust: Add cargo keymaps
      if client.name == "rust_analyzer" then
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "<leader>rr", function()
          vim.cmd("!cargo run")
        end, vim.tbl_extend("force", opts, { desc = "Cargo run" }))
        vim.keymap.set("n", "<leader>rb", function()
          vim.cmd("!cargo build")
        end, vim.tbl_extend("force", opts, { desc = "Cargo build" }))
        vim.keymap.set("n", "<leader>rt", function()
          vim.cmd("!cargo test")
        end, vim.tbl_extend("force", opts, { desc = "Cargo test" }))
        vim.keymap.set("n", "<leader>rc", function()
          vim.cmd("!cargo check")
        end, vim.tbl_extend("force", opts, { desc = "Cargo check" }))
        vim.keymap.set("n", "<leader>rl", function()
          vim.cmd("!cargo clippy")
        end, vim.tbl_extend("force", opts, { desc = "Cargo clippy" }))
      end

      -- HTML: Enable format on save
      if client.name == "html" then
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
            end,
          })
        end
      end
    end
  end,
})

-- Enable LSP servers (configurations are auto-loaded from nvim/lsp/*.lua)
vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "html",
  "cssls",
  "gopls",
  "rust_analyzer",
  "pyright",
  "denols",
  "tsp_server",
})

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
