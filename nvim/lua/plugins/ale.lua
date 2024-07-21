return {
	"dense-analysis/ale",
	-- event = { 'BufReadPre', 'BufNewFile' },
	config = function()
		local g = vim.g
		local b = vim.b
		local rustfmt_path = vim.fn.systemlist("which rustfmt")[1]

		b.ale_rust_rustfmt_executable = rustfmt_path or "rustfmt"

		b.ale_fixers = {
			lua = { "stylua" },
			javascript = { "prettier", "eslint" },
			typescript = { "prettier", "eslint" },
			typescriptreact = { "prettier", "eslint" },
			css = { "prettier", "stylelint" },
			rust = { "rustfmt" },
		}

		b.ale_fix_on_save = 1
		g.ale_fix_on_save = 1
		g.ale_javascript_prettier_use_local_config = 1

		print("rustfmt path: " .. (rustfmt_path or "not found"))
	end,
}
