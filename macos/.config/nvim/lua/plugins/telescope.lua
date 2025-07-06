return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	cmd = {
		"Telescope",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"fdschmidt93/telescope-egrepify.nvim",
	},
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "search [F]iles" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "search [R]ecent files" },
		{ "<leader>fc", function() require('telescope-custom').smart_find_files() end, desc = "smart [F]ind files" },
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
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- 隠しファイルを含める
				},
			},
		})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find old files" })
		
		-- Smart mappings that prioritize recent files
		vim.keymap.set("n", "<leader>f<leader>", function()
			builtin.oldfiles({
				prompt_title = "Recent Files",
				only_cwd = true,  -- Only show files from current working directory
			})
		end, { desc = "Recent files (CWD)" })
		
		vim.keymap.set("n", "<leader>fF", function()
			builtin.find_files({
				prompt_title = "All Files",
				hidden = true,
			})
		end, { desc = "All files (including hidden)" })
	end,
}
