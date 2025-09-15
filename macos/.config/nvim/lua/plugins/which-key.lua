-- Which-key plugin for LazyVim-style space menu
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = { spelling = true },
    defaults = {},
    spec = {
      {
        mode = { "n", "v" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>b", group = "buffer" },
        { "<leader>bp", desc = "Toggle Pin" },
        { "<leader>bP", desc = "Delete Non-Pinned buffers" },
        { "<leader>bo", desc = "Delete Other buffers" },
        { "<leader>br", desc = "Delete buffers to the right" },
        { "<leader>bl", desc = "Delete buffers to the left" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>fp", desc = "Copy relative file path" },
        { "<leader>fP", desc = "Copy absolute file path" },
        { "<leader>fy", desc = "Copy filename" },
        { "<leader>g", group = "git" },
        { "<leader>gc", group = "commits" },
        { "<leader>gh", group = "hunks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>r", group = "rename/rust" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "toggle" },
        { "<leader>u", group = "ui" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "z", group = "fold" },
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(opts.spec)
  end,
}