return {
  event = "VimEnter",
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
}