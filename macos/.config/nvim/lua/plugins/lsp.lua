return {
  -- LSP Configuration without Mason
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      -- This is handled in init.lua using vim.lsp.enable
    end,
  },
  
  -- Enhanced LSP UI
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    event = 'LspAttach',
    config = function()
      require('lspsaga').setup({
        ui = {
          theme = 'round',
          border = 'rounded',
        },
        symbol_in_winbar = {
          enable = false,
        },
        lightbulb = {
          enable = false,
        },
      })
    end,
  },
}