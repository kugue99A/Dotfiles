-- Modern keymap configuration using vim.keymap.set
local keymap = vim.keymap.set

-- Default options for keymaps
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- Disable space in normal mode (since it's our leader)
keymap("n", "<Space>", "<Nop>", opts)

-- Better escape mapping
keymap("i", "jj", "<ESC>", opts)
keymap("i", "kk", "<ESC>", opts) -- Alternative escape

-- Better buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<C-p>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<C-n>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
keymap("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Better indenting (stay in visual mode)
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "J", ":move '>+1<CR>gv=gv", opts)
keymap("v", "K", ":move '<-2<CR>gv=gv", opts)

-- Better paste (don't lose register content)
keymap("x", "<leader>p", [["_dP]], { desc = "Paste without losing register" })

-- Delete to void register
keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Copy to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
keymap("n", "<leader>Y", [["+Y]], { desc = "Copy line to system clipboard" })

-- Copy file path to system clipboard
keymap("n", "<leader>fp", function()
	local path = vim.fn.expand("%:.")
	if path == "" then
		vim.notify("No file in buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", path)
	vim.notify("Copied relative path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })

keymap("n", "<leader>fP", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("No file in buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", path)
	vim.notify("Copied absolute path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute file path" })

keymap("n", "<leader>fy", function()
	local path = vim.fn.expand("%:t")
	if path == "" then
		vim.notify("No file in buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", path)
	vim.notify("Copied filename: " .. path, vim.log.levels.INFO)
end, { desc = "Copy filename" })

-- Search and replace (moved to avoid conflict with telescope)
keymap(
	"n",
	"<leader>sr",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better line navigation
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)

-- Center cursor when jumping
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Quick save and quit
keymap("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", "<cmd>qall<CR>", { desc = "Quit all" })
keymap("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- LazyVim compatible additional keymaps
keymap("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })
keymap("n", "<leader>xl", "<cmd>lopen<CR>", { desc = "Location List" })
keymap("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Quickfix List" })

-- tabs
keymap("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- File explorer
keymap("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Explorer NeoTree (root dir)" })
keymap("n", "<leader>E", "<cmd>Neotree toggle float<CR>", { desc = "Explorer NeoTree (float)" })
keymap("n", "<leader>fe", "<cmd>Neotree toggle<CR>", { desc = "Explorer NeoTree (root dir)" })
keymap("n", "<leader>fE", "<cmd>Neotree toggle float<CR>", { desc = "Explorer NeoTree (float)" })
keymap("n", "<C-f>", function()
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" and vim.fn.filereadable(current_file) == 1 then
    -- Open Neo-tree and reveal current file
    vim.cmd("Neotree reveal")
  else
    -- Just toggle Neo-tree if no file
    vim.cmd("Neotree toggle")
  end
end, { desc = "Reveal current file in explorer" })

-- Terminal mappings
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal left window nav" })
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal down window nav" })
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal up window nav" })
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal right window nav" })

-- LSP keymaps (set on LspAttach)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local buffer = ev.buf

		-- Helper function for LSP keymaps
		local function map(mode, lhs, rhs, desc)
			keymap(mode, lhs, rhs, { buffer = buffer, desc = desc })
		end

		-- Navigation
		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gf", vim.lsp.buf.references, "Find references")
		map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
		map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

		-- Documentation & Diagnostics
		map("n", "K", vim.lsp.buf.hover, "Show hover documentation")
		map("n", "gh", vim.diagnostic.open_float, "Show diagnostics hover")
		map("n", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")
		map("i", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")

		-- Code actions & Refactoring
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
		map("n", "gr", vim.lsp.buf.rename, "Rename symbol")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")

		-- Formatting
		map("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, "Format document")

		-- Diagnostics
		map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
		map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
		map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
		map("n", "<leader>xd", vim.diagnostic.setloclist, "Diagnostics to location list")

		-- Workspace
		map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
		map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
		map("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "List workspace folders")
	end,
})
