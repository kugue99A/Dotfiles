{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yoheikugue";
  home.homeDirectory = "/Users/yoheikugue";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Development tools matching your current setup
    fish
    starship
    lsd
    lazygit
    zellij
    zoxide
    
    # Language servers for development
    lua-language-server
    nil  # Nix LSP
    
    # Other useful tools
    ripgrep
    fd
    bat
    fzf
  ];

  # Neovim configuration - starting simple, can be expanded
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      # Color scheme
      gruvbox-nvim
      
      # Essential plugins
      lualine-nvim
      nvim-tree-lua
      telescope-nvim
      plenary-nvim
      
      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      
      # Treesitter
      (nvim-treesitter.withPlugins (p: [
        p.lua
        p.nix
        p.javascript
        p.typescript
        p.python
        p.go
        p.rust
        p.markdown
      ]))
    ];
    
    extraLuaConfig = ''
      -- Basic settings
      vim.o.number = true
      vim.o.relativenumber = true
      vim.o.expandtab = true
      vim.o.shiftwidth = 2
      vim.o.tabstop = 2
      vim.o.smartindent = true
      vim.o.wrap = false
      vim.o.ignorecase = true
      vim.o.smartcase = true
      vim.o.termguicolors = true
      
      -- Set colorscheme
      vim.cmd.colorscheme("gruvbox")
      
      -- Basic key mappings
      vim.g.mapleader = " "
      
      -- Telescope mappings
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      
      -- LSP setup
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Lua LSP
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = {'vim'}
            }
          }
        }
      })
      
      -- Nix LSP
      lspconfig.nil_ls.setup({
        capabilities = capabilities,
      })
      
      -- CMP setup
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })
      
      -- Lualine setup
      require('lualine').setup({
        options = {
          theme = 'gruvbox'
        }
      })
      
      -- Nvim-tree setup
      require('nvim-tree').setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
    '';
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ls = "lsd";
    };
    shellInit = ''
      # Starship prompt
      starship init fish | source
      
      # Zoxide
      zoxide init fish | source
    '';
  };

  # Starship configuration
  programs.starship = {
    enable = true;
    # You can import your existing starship.toml here if needed
  };

  # Git configuration (if you use git)
  programs.git = {
    enable = true;
    userName = "yoheikugue";
    userEmail = "your-email@example.com";  # Update this
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}