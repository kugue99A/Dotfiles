require("plugins")

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

keymap("i", "jj", "<ESC>", opts)
keymap("n", "<C-p>", ":bprevious<CR>", opts)
keymap("n", "<C-n>", ":bnext<CR>", opts)
keymap("n", "<C-f>", ":VFiler<CR>", opts)

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
	splitright = false, -- オンのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる
}

vim.g.material_style = "palenight"
require("material").setup({
	disable = {
		colored_cursor = false, -- Disable the colored cursor
		borders = false, -- Disable borders between verticaly split windows
		background = true, -- Prevent the theme from setting the background (NeoVim then uses your terminal background)
		term_colors = false, -- Prevent the theme from setting terminal colors
		eob_lines = false, -- Hide the end-of-buffer lines
	},
})
vim.cmd("colorscheme material")

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])

require("lualine").setup({
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

local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["<C-f>"] = actions.close,
				["q"] = actions.close,
			},
		},
	},
})
-- Telescopeウィンドウが開かれたときに、:qで終了すると自動的にTelescopeを閉じる
vim.cmd([[
  autocmd! FileType telescope call v:lua.close_telescope_on_quit()
]])

-- Telescopeを閉じる関数
function _G.close_telescope_on_quit()
	vim.api.nvim_buf_set_keymap(0, "n", "<ESC>", "<CMD>stopinsert<CR><CMD>q<CR>", { noremap = true, silent = true })
end

-- 1. LSP Sever management
require("mason").setup()
require("mason-lspconfig").setup_handlers({
	function(server)
		local opt = {
			-- -- Function executed when the LSP server startup
			-- on_attach = function(client, bufnr)
			--   local opts = { noremap=true, silent=true }
			--   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
			--   vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
			-- end,
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		}
		require("lspconfig")[server].setup(opt)
	end,
})

-- 2. build-in LSP function
-- keyboard shortcut
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] =
	vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
-- Reference highlight
vim.cmd([[
  set updatetime=500
  highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  augroup lsp_document_highlight
    autocmd!
    autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
  augroup END
]])

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
		["<C-l>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	experimental = {
		ghost_text = true,
	},
})

-- indent_blankline ---------------
vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup({
	show_end_of_line = true,
	space_char_blankline = " ",
})
-----------------------------------

-- filer --------------------------
-- -- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
--
-- -- set termguicolors to enable highlight groups
-- vim.opt.termguicolors = true
--
-- -- empty setup using defaults
-- require("nvim-tree").setup()
--
-- local function my_on_attach(bufnr)
-- 	local api = require("nvim-tree.api")
--
-- 	local function opts(desc)
-- 		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
-- 	end
--
-- 	-- default mappings
-- 	api.config.mappings.default_on_attach(bufnr)
--
-- 	-- custom mappings
-- 	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
-- 	vim.keymap.set("n", "l", api.node.open.tab, opts("Open: New Tab"))
-- 	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
-- end
--
-- require("nvim-tree").setup({
-- 	sort_by = "case_sensitive",
-- 	on_attach = my_on_attach,
-- 	view = {
-- 		width = 30,
-- 	},
-- 	renderer = {
-- 		group_empty = true,
-- 	},
-- 	filters = {
-- 		dotfiles = true,
-- 	},
-- })
local action = require("vfiler/action")
require("vfiler/config").setup({
	options = {
		auto_cd = true,
		auto_resize = true,
		columns = "indent,devicons,name",
		find_file = false,
		header = true,
		keep = false,
		listed = true,
		name = "",
		show_hidden_files = true,
		sort = "name",
		layout = "floating",
		height = 40,
		new = false,
		quit = false,
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
vim.cmd([[autocmd VimEnter * :VFiler]])
----------------------------------------------

-- formatting on save ------------------------

local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- apply whatever logic you want (in this example, we'll only use null-ls)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local null_ls = require("null-ls")
require("null-ls").setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.eslint,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylelint,
		null_ls.builtins.formatting.gofmt,
		null_ls.builtins.formatting.rustfmt,
		null_ls.builtins.formatting.ruff,
		null_ls.builtins.formatting.fish_indent,
	},
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					lsp_formatting(bufnr)
				end,
			})
		end
	end,
})

----------------------------------------------
