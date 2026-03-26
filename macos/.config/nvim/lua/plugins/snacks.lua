-- snacks.nvim: Image viewer and utilities
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = false, -- WezTerm doesn't support inline (Unicode placeholders)
        float = true, -- Use floating window instead
      },
    },
  },
}
