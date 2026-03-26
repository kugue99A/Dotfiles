-- Modern Neovim initialization
-- Set leader keys before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set language to English (modern approach)
vim.cmd.language("en_US.UTF-8")

-- Add mise bin directories to PATH for LSP servers (deferred to avoid blocking startup)
-- vim.fn.system() is expensive (~30ms each), so we defer until just before LSP needs it
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local mise_bin = vim.fn.expand("~/.local/bin/mise")
    if vim.fn.executable(mise_bin) == 1 then
      local path_additions = {}
      local node_path_output = vim.fn.system(mise_bin .. " where node 2>/dev/null")
      if vim.v.shell_error == 0 and node_path_output ~= "" then
        table.insert(path_additions, vim.trim(node_path_output) .. "/bin")
      end
      local ts_ls_path_output = vim.fn.system(mise_bin .. " where npm:typescript-language-server 2>/dev/null")
      if vim.v.shell_error == 0 and ts_ls_path_output ~= "" then
        table.insert(path_additions, vim.trim(ts_ls_path_output) .. "/bin")
      end
      if #path_additions > 0 then
        vim.env.PATH = table.concat(path_additions, ":") .. ":" .. vim.env.PATH
      end
    end
  end,
})

-- Load lazy.nvim plugin manager first
require("config.lazy")

-- Ensure faster startup by loading core modules efficiently
local core_modules = {
  "core.options",
  "core.keymaps", 
  "core.lsp",
  "core.highlights",
}

-- Load core modules with error handling
for _, module in ipairs(core_modules) do
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("Failed to load %s: %s", module, err),
      vim.log.levels.ERROR,
      { title = "Init Error" }
    )
  end
end