return {
  event = "VimEnter",
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
}
