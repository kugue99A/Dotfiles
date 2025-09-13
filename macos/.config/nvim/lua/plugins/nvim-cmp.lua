-- Autocompletion configuration with nvim-cmp
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Completion sources
    "hrsh7th/cmp-nvim-lsp",     -- LSP completions
    "hrsh7th/cmp-buffer",       -- Buffer completions
    "hrsh7th/cmp-path",         -- Path completions
    "hrsh7th/cmp-cmdline",      -- Command line completions
    "Jezda1337/nvim-html-css",  -- Enhanced HTML/CSS completions
    
    -- Snippet engine and completions
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets", -- Pre-configured snippets
      },
    },
    "saadparwaiz1/cmp_luasnip", -- LuaSnip completions
    
    -- Icons for completion menu
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Helper function for tab/shift-tab behavior
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      
      -- Completion menu behavior
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      
      -- View configuration
      view = {
        entries = { name = "custom", selection_order = "near_cursor" },
      },
      
      mapping = cmp.mapping.preset.insert({
        -- Navigate completion menu
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        
        -- Scroll documentation
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        
        -- Complete/cancel
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        
        -- Accept completion
        ["<CR>"] = cmp.mapping.confirm({ 
          behavior = cmp.ConfirmBehavior.Replace,
          select = false, -- Only confirm explicitly selected items
        }),
        
        -- Super-Tab like behavior
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "html-css", priority = 700 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),
      
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
          show_labelDetails = true,
          
          -- Custom icons
          symbol_map = {
            Text = "󰉿",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "󰑭",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "󰈇",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "󰙅",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "",
          },
          
          before = function(entry, vim_item)
            -- Show source
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              ["html-css"] = "[HTML]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            
            return vim_item
          end,
        }),
      },
      
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          max_height = 7,
          max_width = 50,
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          max_height = 15,
          max_width = 60,
          winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
        }),
      },
      
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
    })
    
    -- Command line completions
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
    })
    
    -- File type specific configurations
    -- HTML files
    cmp.setup.filetype({ "html" }, {
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "html-css", priority = 900 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),
    })
    
    -- CSS files
    cmp.setup.filetype({ "css", "scss", "less" }, {
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "html-css", priority = 900 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
      }),
    })
    
    -- JSX/TSX files
    cmp.setup.filetype({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, {
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "html-css", priority = 800 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),
    })
    
    -- Custom highlight groups
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    vim.api.nvim_set_hl(0, "CmpNormal", { bg = "#1e1e1e" })
    vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#565c64" })
    vim.api.nvim_set_hl(0, "CmpSelection", { bg = "#2d3142" })
    vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#1e1e1e" })
    vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#565c64" })
  end,
}