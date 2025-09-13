-- Modern keymap configuration using vim.keymap.set
local keymap = vim.keymap.set

-- Default options for keymaps
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- Disable space in normal mode (since it's our leader)
keymap("n", "<Space>", "<Nop>", opts)

-- Better escape mapping
keymap("i", "jj", "<ESC>", opts)
keymap("i", "kk", "<ESC>", opts)  -- Alternative escape

-- Better buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

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

-- Search and replace
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], 
  { desc = "Search and replace word under cursor" })

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

-- Neo-tree file explorer
keymap("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>E", "<cmd>Neotree focus<CR>", { desc = "Focus file explorer" })
keymap("n", "<C-f>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

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
    map("n", "gr", vim.lsp.buf.references, "Go to references")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
    
    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "Show hover documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Show signature help")
    
    -- Code actions
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    
    -- Formatting
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format document")
    
    -- Diagnostics
    map("n", "<leader>e", vim.diagnostic.open_float, "Show line diagnostics")
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to location list")
    
    -- Workspace
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")
  end,
})