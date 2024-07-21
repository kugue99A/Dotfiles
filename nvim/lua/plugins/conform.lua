return {
	"stevearc/conform.nvim",
	opts = {},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				python = { "isort", "black" },
				-- You can customize some of the format options for the filetype (:help conform.format)
				rust = { "rustfmt", lsp_format = "fallback" },
				-- Conform will run the first available formatter
				javascript = { "prettier", "eslint", stop_after_first = true },
				typescript = { "prettier", "eslint", stop_after_first = true },
				typescriptreact = { "prettier", "eslint", stop_after_first = true },
				css = { "prettier", "stylelint", stop_after_first = true },
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_fallback = true,
				quiet = false,
			},
		})
	end,
}
