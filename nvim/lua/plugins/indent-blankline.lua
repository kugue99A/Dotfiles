return {
	event = { "BufReadPre", "BufNewFile" },
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	---@module "ibl"
	---@type ibl.config
	opts = {},
	config = function()
		require("ibl").setup({
			indent = {
				char = "▏",
				tab_char = "▏",
			},
		})
	end,
}
