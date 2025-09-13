-- Modern Neovim initialization
-- Set leader keys before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Set language to English (modern approach)
vim.cmd.language("en_US.UTF-8")

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