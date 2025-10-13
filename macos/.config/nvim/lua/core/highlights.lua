-- Modern highlight configuration
local M = {}

-- Helper function to set highlight groups
local function set_hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Auto command to set highlights after colorscheme changes
local function apply_highlights()
	-- Enhanced cursor line
	set_hl("CursorLineNr", { bold = true })

	-- Better visual selection
	set_hl("Visual", { bg = "#364a82", fg = "NONE" })

	-- Improved search highlighting
	set_hl("Search", { bg = "#ff9e64", fg = "#1a1b26", bold = true })
	set_hl("IncSearch", { bg = "#f7768e", fg = "#1a1b26", bold = true })

	-- Float window borders
	set_hl("FloatBorder", { fg = "#565f89", bg = "NONE" })
	set_hl("NormalFloat", { bg = "#1a1b26" })

	-- Diagnostic highlights
	set_hl("DiagnosticError", { fg = "#f7768e" })
	set_hl("DiagnosticWarn", { fg = "#e0af68" })
	set_hl("DiagnosticInfo", { fg = "#7aa2f7" })
	set_hl("DiagnosticHint", { fg = "#1abc9c" })

	-- Better diff colors
	set_hl("DiffAdd", { bg = "#20303b", fg = "#449dab" })
	set_hl("DiffChange", { bg = "#1f2335", fg = "#6183bb" })
	set_hl("DiffDelete", { bg = "#37222c", fg = "#914c54" })
	set_hl("DiffText", { bg = "#394b70", fg = "#394b70", bold = true })

	-- Terminal colors
	vim.g.terminal_color_0 = "#15161e" -- black
	vim.g.terminal_color_1 = "#f7768e" -- red
	vim.g.terminal_color_2 = "#9ece6a" -- green
	vim.g.terminal_color_3 = "#e0af68" -- yellow
	vim.g.terminal_color_4 = "#7aa2f7" -- blue
	vim.g.terminal_color_5 = "#bb9af7" -- magenta
	vim.g.terminal_color_6 = "#7dcfff" -- cyan
	vim.g.terminal_color_7 = "#a9b1d6" -- white
	vim.g.terminal_color_8 = "#414868" -- bright black
	vim.g.terminal_color_9 = "#f7768e" -- bright red
	vim.g.terminal_color_10 = "#9ece6a" -- bright green
	vim.g.terminal_color_11 = "#e0af68" -- bright yellow
	vim.g.terminal_color_12 = "#7aa2f7" -- bright blue
	vim.g.terminal_color_13 = "#bb9af7" -- bright magenta
	vim.g.terminal_color_14 = "#7dcfff" -- bright cyan
	vim.g.terminal_color_15 = "#c0caf5" -- bright white

	-- Plugin-specific highlights
	-- Notification backgrounds (nvim-notify)
	local notify_groups = {
		"NotifyBackground",
		"NotifyERRORBackground",
		"NotifyWARNBackground",
		"NotifyINFOBackground",
		"NotifyDEBUGBackground",
		"NotifyTRACEBackground",
	}

	for _, group in ipairs(notify_groups) do
		set_hl(group, { bg = "NONE" })
	end

	-- Telescope highlights
	set_hl("TelescopeBorder", { fg = "#565f89" })
	set_hl("TelescopePromptBorder", { fg = "#ff9e64" })
	set_hl("TelescopeResultsBorder", { fg = "#565f89" })
	set_hl("TelescopePreviewBorder", { fg = "#565f89" })

	-- LSP reference highlights
	set_hl("LspReferenceText", { bg = "#3b4261", underline = false })
	set_hl("LspReferenceRead", { bg = "#3b4261", underline = false })
	set_hl("LspReferenceWrite", { bg = "#3b4261", underline = false, bold = true })

	-- Better completion menu
	set_hl("Pmenu", { bg = "#1a1b26", fg = "#c0caf5" })
	set_hl("PmenuSel", { bg = "#7aa2f7", fg = "#1a1b26", bold = true })
	set_hl("PmenuSbar", { bg = "#16161e" })
	set_hl("PmenuThumb", { bg = "#7aa2f7" })
end

-- Create autocommand to apply highlights
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
	callback = apply_highlights,
})

-- Apply highlights immediately
apply_highlights()

return M

