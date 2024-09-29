return {
	"stevearc/conform.nvim",
	opts = {},
	event = { "VimEnter", "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				rust = { "rustfmt", lsp_format = "fallback" },
				go = { "gofmt", lsp_format = "fallback" },
				javascript = { "biome", "prettier", "eslint_d", stop_after_first = true },
				typescript = { "biome", "prettier", "eslint_d", stop_after_first = true },
				typescriptreact = { "biome-check", "prettier", "eslint_d", stop_after_first = true },
				css = { "stylelint", "prettier", stop_after_first = true },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = {
				timeout_ms = 2000,
			},
		})
	end,
}
