-- Neo-tree file explorer configuration
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer NeoTree" },
    { "<leader>E", "<cmd>Neotree toggle float<CR>", desc = "Explorer NeoTree (float)" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    sort_case_insensitive = false,
    
    default_component_configs = {
      container = {
        enable_character_fade = true,
      },
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
        highlight = "NeoTreeIndentMarker",
        with_expanders = nil,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󰜌",
        default = "*",
        highlight = "NeoTreeFileIcon",
      },
      modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
      },
      git_status = {
        symbols = {
          added     = "✚",
          modified  = "",
          deleted   = "✖",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
    },
    
    window = {
      position = "current",
      width = 40,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["<space>"] = {
          "toggle_node",
          nowait = false,
        },
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["l"] = "open",
        ["h"] = "close_node",
        ["<esc>"] = "cancel",
        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["t"] = "open_tabnew",
        ["w"] = "open_with_window_picker",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["a"] = {
          "add",
          config = {
            show_path = "relative",
          },
        },
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy",
        ["m"] = "move",
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
        ["i"] = "show_file_details",
        ["<C-f>"] = "close_window",
      },
    },
    
    nesting_rules = {},
    
    filesystem = {
      filtered_items = {
        visible = true,          -- Show hidden files by default
        hide_dotfiles = false,   -- Always show dotfiles
        hide_gitignored = false, -- Always show gitignored files
        hide_hidden = false,     -- Always show hidden files
        hide_by_name = {
          --"node_modules"
        },
        hide_by_pattern = {
          --"*.meta",
          --"*/src/*/tsconfig.json",
        },
        always_show = {
          ".gitignore",
          ".env",
          ".config",
          --".gitignored",
        },
        never_show = {
          ".DS_Store",
          "thumbs.db",
        },
        never_show_by_pattern = {
          --".null-ls_*",
        },
      },
      follow_current_file = {
        enabled = false,
        leave_dirs_open = false,
      },
      group_empty_dirs = false,
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = false,
      window = {
        mappings = {
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["/"] = "fuzzy_finder",
          ["D"] = "fuzzy_finder_directory",
          ["#"] = "fuzzy_sorter",
          ["f"] = "filter_on_submit",
          ["<c-x>"] = "clear_filter",
          ["[g"] = "prev_git_modified",
          ["]g"] = "next_git_modified",
          ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
          ["oc"] = "order_by_created",
          ["od"] = "order_by_diagnostics",
          ["og"] = "order_by_git_status",
          ["om"] = "order_by_modified",
          ["on"] = "order_by_name",
          ["os"] = "order_by_size",
          ["ot"] = "order_by_type",
        },
        fuzzy_finder_mappings = {
          ["<down>"] = "move_cursor_down",
          ["<C-n>"] = "move_cursor_down",
          ["<up>"] = "move_cursor_up",
          ["<C-p>"] = "move_cursor_up",
        },
      },
      
      commands = {},
    },
    
    buffers = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      group_empty_dirs = true,
      show_unloaded = true,
      window = {
        mappings = {
          ["bd"] = "buffer_delete",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
          ["oc"] = "order_by_created",
          ["od"] = "order_by_diagnostics",
          ["om"] = "order_by_modified",
          ["on"] = "order_by_name",
          ["os"] = "order_by_size",
          ["ot"] = "order_by_type",
        },
      },
    },
    
    git_status = {
      window = {
        position = "float",
        mappings = {
          ["A"]  = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
          ["gg"] = "git_commit_and_push",
          ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
          ["oc"] = "order_by_created",
          ["od"] = "order_by_diagnostics",
          ["om"] = "order_by_modified",
          ["on"] = "order_by_name",
          ["os"] = "order_by_size",
          ["ot"] = "order_by_type",
        },
      },
    },
  },
  
  config = function(_, opts)
    require("neo-tree").setup(opts)

    -- Open neo-tree when opening a directory
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("NeoTreeInit", { clear = true }),
      callback = function()
        local f = vim.fn.expand("%:p")
        if vim.fn.isdirectory(f) ~= 0 then
          -- Defer to avoid timing issues with nui.nvim
          vim.schedule(function()
            -- Delete the directory buffer first
            vim.cmd("bwipeout")
            vim.cmd("Neotree current dir=" .. vim.fn.fnameescape(f))
          end)
          return true
        end
      end,
    })
    
    
    -- Custom highlights
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#fe8019" })  -- Orange for directories
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#83a598" })  -- Blue for directory names
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#fabd2f" })    -- Yellow for modified files
    vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = "#b8bb26" })       -- Green for added files
    vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#fb4934" })     -- Red for deleted files
    vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = "#665c54" })     -- Gray for ignored files
    vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#d3869b" })   -- Magenta for untracked files
  end,
}