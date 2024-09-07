return {
	"stevearc/conform.nvim",
	opts = {},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				go = { "gopls", lsp_fallback = "fallback" },
				javascript = { "prettier", "eslint", stop_after_first = true },
				typescript = { "prettier", "eslint", stop_after_first = true },
				typescriptreact = { "prettier", "eslint", stop_after_first = true },
				css = { "prettier", "stylelint", stop_after_first = true },
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_fallback = true,
			},
		})
	end,
}
