return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	cmd = {
		"Telescope",
	},
	event = { "VimEnter", "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"fdschmidt93/telescope-egrepify.nvim",
	},
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "search [F]iles" },
	},
	config = function()
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["jj"] = actions.close,
					},
					n = { ["q"] = actions.close },
				},
				layout_strategy = "vertical",
			},
		})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
	end,
}
