vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.api.nvim_exec("language en_US", true)

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

require("config.lazy")

keymap("i", "jj", "<ESC>", opts)
keymap("n", "<C-p>", ":bprevious<CR>", opts)
keymap("n", "<C-n>", ":bnext<CR>", opts)
-- keymap("n", "<C-f>", ":VFiler<CR>", opts)
keymap("n", "<Space>", "<Nop>", { noremap = true, silent = true })

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
	splitbelow = false,
	splitright = false,
	-- Performance optimizations
	ttyfast = true,
	-- Reduce shutdown time
	shada = "!,'100,<50,s10,h",
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- LSP Server management (using vim.lsp.enable with local config files)
local lsp_servers = {
	"lua_ls",
	"denols",
	"tsserver",
	"gopls",
	"rust_analyzer",
	"pyright",
}

for _, server in ipairs(lsp_servers) do
	local config_path = vim.fn.stdpath('config') .. '/lsp/' .. server .. '.lua'
	local config = {}
	
	-- Load server-specific configuration if it exists
	if vim.fn.filereadable(config_path) == 1 then
		local ok, server_config = pcall(dofile, config_path)
		if ok and type(server_config) == 'table' then
			config = server_config
		end
	end
	
	vim.lsp.enable(server, config)
end

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)
	end,
})

-- Fix notify background highlight issue
vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#000000", blend = 100 })
vim.api.nvim_set_hl(0, "NotifyERRORBackground", { bg = "#000000", blend = 100 })
vim.api.nvim_set_hl(0, "NotifyWARNBackground", { bg = "#000000", blend = 100 })
vim.api.nvim_set_hl(0, "NotifyINFOBackground", { bg = "#000000", blend = 100 })
vim.api.nvim_set_hl(0, "NotifyDEBUGBackground", { bg = "#000000", blend = 100 })
vim.api.nvim_set_hl(0, "NotifyTRACEBackground", { bg = "#000000", blend = 100 })
