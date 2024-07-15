vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
  }
  use {
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  }
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/vim-vsnip"

  use 'nvim-lualine/lualine.nvim'

  use 'kyazdani42/nvim-web-devicons'

  use 'nvim-tree/nvim-tree.lua'
  use 'nvim-tree/nvim-web-devicons'

  use 'obaland/vfiler.vim'
  use 'obaland/vfiler-column-devicons'

  use 'dense-analysis/ale'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'lukas-reineke/indent-blankline.nvim'

  use 'marko-cerovac/material.nvim'
end)
