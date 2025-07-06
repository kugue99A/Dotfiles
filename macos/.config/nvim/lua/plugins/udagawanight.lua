return {
	event = "VimEnter",
	"kugue99A/udagawanight.nvim",
	config = function()
		require("udagawanight").setup({
			terminal_colors = true, -- add neovim terminal colors
			transparent_mode = true,
		})
		vim.cmd("colorscheme udagawanight")
	end,
}
