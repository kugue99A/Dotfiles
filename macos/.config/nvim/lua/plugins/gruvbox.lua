return {
	event = "VimEnter",
	"ellisonleao/gruvbox.nvim",
	config = function()
		require("gruvbox").setup({
			terminal_colors = true, -- add neovim terminal colors
			transparent_mode = true,
		})
		-- vim.cmd("colorscheme gruvbox")
	end,
}

