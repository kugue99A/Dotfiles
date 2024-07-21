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
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- 1. LSP Sever management
require("mason").setup()
require("mason-lspconfig").setup_handlers({
	function(server)
		local opt = {
			capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
		}
		require("lspconfig")[server].setup(opt)
	end,
})
