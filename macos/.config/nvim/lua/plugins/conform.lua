-- Code formatting with conform.nvim
return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				rust = { "rustfmt", lsp_format = "fallback" },
				go = { "gofmt", lsp_format = "fallback" },
				json = { "biome-check", "prettier", stop_after_first = true },
				javascript = { "prettier", "biome-check", "eslint_d", stop_after_first = true },
				typescript = { "prettier", "biome-check", "eslint_d", stop_after_first = true },
				typescriptreact = { "prettier", "biome-check", "eslint_d", stop_after_first = true },
				css = { "stylelint", "biome-check", stop_after_first = true },
				scss = { "stylelint", "prettier", stop_after_first = true },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			formatters = {
				-- Prettier 3.x は設定ファイルがないとフォーマットしないため、
				-- require_cwd = true で設定ファイルがある場合のみ実行し、
				-- なければ次のフォーマッター（biome等）にフォールバックさせる
				prettier = {
					require_cwd = true,
				},
			},
			format_on_save = {
				timeout_ms = 2000,
				lsp_format = "fallback",
			},
		})
	end,
}

