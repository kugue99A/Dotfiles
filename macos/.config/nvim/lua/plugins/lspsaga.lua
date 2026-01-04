-- LSP UI enhancement with lspsaga
return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- UI settings
    ui = {
      border = "rounded",
      code_action = "💡",
    },
    -- Lightbulb for code actions
    lightbulb = {
      enable = false,
    },
    -- Symbol in winbar
    symbol_in_winbar = {
      enable = false,
    },
  },
  keys = {
    -- Hover
    { "gh", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover Doc" },

    -- Definition
    { "gd", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto Definition" },
    { "gD", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek Definition" },
    { "gt", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto Type Definition" },

    -- References & Finder
    { "gr", "<cmd>Lspsaga finder<cr>", desc = "Find References" },

    -- Rename
    { "gn", "<cmd>Lspsaga rename<cr>", desc = "Rename Symbol" },

    -- Code Action
    { "ga", "<cmd>Lspsaga code_action<cr>", desc = "Code Action" },

    -- Diagnostics
    { "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Prev Diagnostic" },
    { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },
    { "gl", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line Diagnostics" },

    -- Outline
    { "<leader>o", "<cmd>Lspsaga outline<cr>", desc = "Toggle Outline" },

    -- Call hierarchy
    { "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incoming Calls" },
    { "<leader>co", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing Calls" },
  },
}
