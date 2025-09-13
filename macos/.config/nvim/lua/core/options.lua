-- Modern Neovim options configuration
local opt = vim.opt

-- Ensure files are modifiable by default
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    vim.bo.modifiable = true
  end,
})

-- File encoding and format
opt.fileencoding = "utf-8"
opt.fileformats = { "unix", "dos", "mac" }

-- UI and display
opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false
opt.laststatus = 3  -- Global statusline
opt.cmdheight = 1   -- Reduced from 2 (modern default)
opt.pumheight = 15  -- Better popup menu height
opt.pumblend = 10   -- Modern transparency
opt.winblend = 0

-- Search and completion
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.completeopt = { "menu", "menuone", "noselect" }  -- Modern completion
opt.wildmode = { "longest:full", "full" }
opt.wildoptions = "pum"

-- Indentation and formatting
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true  -- Better line wrapping
opt.wrap = false

-- File handling
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000

-- Performance and behavior
opt.updatetime = 200  -- Faster than 300ms
opt.timeoutlen = 500  -- More reasonable timeout
opt.ttimeoutlen = 10  -- Fast key code timeout
opt.lazyredraw = false  -- Don't use lazyredraw in modern Neovim
opt.synmaxcol = 240    -- Syntax highlight limit

-- Scrolling and movement
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true  -- Modern smooth scrolling

-- Window splitting
opt.splitbelow = true   -- More intuitive splits
opt.splitright = true
opt.splitkeep = "screen"  -- Keep text in view when splitting

-- Mouse and clipboard
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.mousemodel = "extend"

-- Misc modern settings
opt.conceallevel = 0
opt.title = true
opt.titlestring = "%<%F%=%l/%L - nvim"
opt.confirm = true      -- Confirm before closing unsaved buffers
opt.virtualedit = "block"  -- Better visual block mode
opt.inccommand = "split"   -- Preview substitutions
opt.jumpoptions = "view"   -- Better jump behavior

-- Shell configuration
if vim.fn.executable("fish") == 1 then
  opt.shell = "fish"
else
  opt.shell = vim.env.SHELL or "/bin/bash"
end

-- Disable some built-in plugins for better performance
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1