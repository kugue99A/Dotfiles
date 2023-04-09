require 'plugins'

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

keymap('i', 'jj', '<ESC>', opts)
keymap('n', '<C-p>', ':bprevious<CR>', opts)
keymap('n', '<C-n>', ':bnext<CR>', opts)
keymap('n', '<C-f>', ':Telescope file_browser path=%:p:h select_buffer=false<CR>', opts)

local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  title = true,
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 2,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,
  hlsearch = true,
  ignorecase = true,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 300,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  shell = "fish",
  backupskip = { "/tmp/*", "/private/tmp/*" },
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  number = true,
  relativenumber = false,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = false,
  winblend = 0,
  wildoptions = "pum",
  pumblend = 5,
  scrolloff = 8,
  sidescrolloff = 8,
  guifont = "monospace:h17",
  splitbelow = false, -- オンのとき、ウィンドウを横分割すると新しいウィンドウはカレントウィンドウの下に開かれる
  splitright = false, -- オンのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる
}

vim.api.nvim_command [[
  colorscheme iceberg
]]

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])

require 'lualine'.setup {
  tabline = {
    lualine_a = {
      {
        'buffers',
        component_separators = { left = ' ', right = '' },
        section_separators = { left = '', right = '' },
        buffers_color = {
          active = { bg = '#dcdfe7', fg = '#282828' },
          inactive = { bg = '#282828', fg = '#dcdfe7' },
        },
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
}


local actions = require('telescope.actions')
local fb_actions = require "telescope".extensions.file_browser.actions
require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["<C-f>"] = actions.close,
        ["q"] = actions.close
      },
    },
  },
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
      initial_mode = "normal",
      previewer = false,
      hidden = true,
      mappings = {
        ["i"] = {
        },
        ["n"] = {
          ["/"] = function ()
            vim.cmd('startinsert')
          end,
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["cc"] = fb_actions.copy,
          ["dd"] = fb_actions.remove,
          ["r"] = fb_actions.rename,
        },
      },
    },
  },
}
require("telescope").load_extension "file_browser"
-- Telescopeウィンドウが開かれたときに、:qで終了すると自動的にTelescopeを閉じる
vim.cmd([[
  autocmd! FileType telescope call v:lua.close_telescope_on_quit()
]])

-- Telescopeを閉じる関数
function _G.close_telescope_on_quit()
  vim.api.nvim_buf_set_keymap(0, 'n', '<ESC>', '<CMD>stopinsert<CR><CMD>q<CR>', { noremap = true, silent = true })
end

-- 1. LSP Sever management
require('mason').setup()
require('mason-lspconfig').setup_handlers({ function(server)
  local opt = {
    -- -- Function executed when the LSP server startup
    -- on_attach = function(client, bufnr)
    --   local opts = { noremap=true, silent=true }
    --   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    --   vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
    -- end,
    capabilities = require('cmp_nvim_lsp').default_capabilities()
  }
  require('lspconfig')[server].setup(opt)
end })

-- 2. build-in LSP function
-- keyboard shortcut
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
-- Reference highlight
vim.cmd [[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]]

-- 3. completion (hrsh7th/nvim-cmp)
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    -- { name = "buffer" },
    -- { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})

-- Configure ALE for auto-formatting
vim.cmd([[
  let g:ale_linters = {
        \ 'javascript': ['eslint'],
        \ 'typescript': ['eslint'],
        \ 'typescriptreact': ['eslint'],
        \ 'html': ['prettier'],
        \ 'css': ['prettier'],
        \ 'scss': ['prettier'],
        \ 'json': ['prettier'],
        \ }
  let g:ale_fixers = {
        \ 'javascript': ['prettier', 'eslint'],
        \ 'typescript': ['prettier', 'eslint'],
        \ 'typescriptreact': ['prettier', 'eslint'],
        \ 'json': ['prettier'],
        \ 'html': ['prettier'],
        \ 'css': ['stylelint'],
        \ 'scss': ['stylelint'],
        \ 'go': ['gopls'],
        \ }
  let g:ale_fix_on_save = 1
]])

-- Key mapping for manual formatting
vim.api.nvim_set_keymap('n', '<leader>f', ':ALEFix<CR>', { noremap = true, silent = true })
