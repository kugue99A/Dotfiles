return {
  'editorconfig/editorconfig-vim',
  {
    'ellisonleao/gruvbox.nvim',
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        transparent_mode = true,
      })
      vim.cmd("colorscheme gruvbox")
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        tabline = {
          lualine_a = {
            {
              "buffers",
              component_separators = { left = " ", right = "" },
              section_separators = { left = "", right = "" },
              buffers_color = {
                active = { bg = "#dcdfe7", fg = "#282828" },
                inactive = { bg = "#282828", fg = "#dcdfe7" },
              },
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  },
  {
    'obaland/vfiler.vim',
    config = function()
      local action = require("vfiler/action")
      require("vfiler/config").setup({
        options = {
          auto_cd = true,
          auto_resize = true,
          columns = "indent,devicons,name",
          find_file = true,
          header = true,
          keep = false,
          listed = true,
          name = "",
          show_hidden_files = true,
          sort = "name",
          layout = "floating",
          height = 40,
          new = false,
          quit = true,
          toggle = true,
          row = 0,
          col = 0,
          blend = 0,
          border = "rounded",
          zindex = 200,
          git = {
            enabled = true,
            ignored = true,
            untracked = true,
          },
          preview = {
            layout = "floating",
            width = 0,
            height = 0,
          },
          mappings = {
            ["."] = action.toggle_show_hidden,
            ["<BS>"] = action.change_to_parent,
            ["<C-l>"] = action.reload,
            ["<C-p>"] = action.toggle_auto_preview,
            ["<C-r>"] = action.sync_with_current_filer,
            ["<C-s>"] = action.toggle_sort,
            ["<CR>"] = action.open,
            ["<S-Space>"] = function(vfiler, context, view)
              action.toggle_select(vfiler, context, view)
              action.move_cursor_up(vfiler, context, view)
            end,
            ["<Space>"] = function(vfiler, context, view)
              action.toggle_select(vfiler, context, view)
              action.move_cursor_down(vfiler, context, view)
            end,
            ["<Tab>"] = action.switch_to_filer,
            ["~"] = action.jump_to_home,
            ["*"] = action.toggle_select_all,
            ["\\"] = action.jump_to_root,
            ["cc"] = action.copy_to_filer,
            ["dd"] = action.delete,
            ["gg"] = action.move_cursor_top,
            ["b"] = action.list_bookmark,
            ["h"] = action.close_tree_or_cd,
            ["j"] = action.loop_cursor_down,
            ["k"] = action.loop_cursor_up,
            ["l"] = action.open_tree,
            ["mm"] = action.move_to_filer,
            ["p"] = action.toggle_preview,
            ["q"] = action.quit,
            ["r"] = action.rename,
            ["s"] = action.open_by_split,
            ["t"] = action.open_by_tabpage,
            ["v"] = action.open_by_vsplit,
            ["x"] = action.execute_file,
            ["yy"] = action.yank_path,
            ["B"] = action.add_bookmark,
            ["C"] = action.copy,
            ["D"] = action.delete,
            ["G"] = action.move_cursor_bottom,
            ["J"] = action.jump_to_directory,
            ["K"] = action.new_directory,
            ["L"] = action.switch_to_drive,
            ["M"] = action.move,
            ["N"] = action.new_file,
            ["P"] = action.paste,
            ["S"] = action.change_sort,
            ["U"] = action.clear_selected_all,
            ["YY"] = action.yank_name,
          },
        },
      })
      
      vim.g.loaded_netrwPlugin = 1
    end
  },
  'obaland/vfiler-column-devicons',
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
     dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          -- { name = 'buffer' },
          -- { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-l>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
        }),
        experimental = {
          ghost_text = true,
        },
      })
    end
  },
  'neovim/nvim-lspconfig',
  'hrsh7th/nvim-cmp',
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
     "nvimdev/lspsaga.nvim",
    event = { "LspAttach" },
    dependencies = {
      -- 'nvim-treesitter/nvim-treesitter',
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        finder = {
          max_height = 0.6,
          default = "tyd+ref+imp+def",
          keys = {
            toggle_or_open = "<CR>",
            vsplit = { "v", "[" },
            split = { "s", "}" },
            tabnew = "t",
            tab = "T",
            quit = "q",
            close = "<Esc>",
          },
          methods = {
            tyd = "textDocument/typeDefinition",
          },
        },
        -- https://nvimdev.github.io/lspsaga/lightbulb/
        -- hide lightbulb icon in anumber col  number col
        ui = {
          code_action = "",
        },
      })

      vim.keymap.set("n", "<leader>,", "<Cmd>Lspsaga finder<CR>", { desc = "Telescope: live grep args" })
    end, 'hrsh7th/cmp-cmdline',
}
