-- Code formatting with conform.nvim
return {
	"stevearc/conform.nvim",
	opts = {},
	event = { "VimEnter", "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				rust = { "rustfmt", lsp_format = "fallback" },
				go = { "gofmt", lsp_format = "fallback" },
				json = { "biome-check", stop_after_first = true },
				-- javascript = { "biome-check", "prettier", "eslint_d", stop_after_first = true },
				-- typescript = { "biome-check", "prettier", "eslint_d", stop_after_first = true },
				-- typescriptreact = { "biome", "prettier", "eslint_d", stop_after_first = true },
				javascript = { "prettier", "eslint_d", stop_after_first = true },
				typescript = { "prettier", "eslint_d", stop_after_first = true },
				typescriptreact = { "prettier", "eslint_d", stop_after_first = true },
				css = { "stylelint", "biome", "biome-check", stop_after_first = true },
				scss = { "stylelint", "prettier", stop_after_first = true },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = {
				timeout_ms = 2000,
			},
		})
	end,
}

