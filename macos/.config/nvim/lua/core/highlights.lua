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
	set_hl("Visual", { bg = "#3c3836", fg = "NONE" })

	-- Improved search highlighting
	set_hl("Search", { bg = "#fe8019", fg = "#1d2021", bold = true })
	set_hl("IncSearch", { bg = "#fb4934", fg = "#1d2021", bold = true })

	-- Float window borders
	set_hl("FloatBorder", { fg = "#665c54", bg = "NONE" })
	set_hl("NormalFloat", { bg = "#1d2021" })

	-- Diagnostic highlights
	set_hl("DiagnosticError", { fg = "#fb4934" })
	set_hl("DiagnosticWarn", { fg = "#fabd2f" })
	set_hl("DiagnosticInfo", { fg = "#83a598" })
	set_hl("DiagnosticHint", { fg = "#8ec07c" })

	-- Better diff colors
	set_hl("DiffAdd", { bg = "#2ea043", fg = "#ffffff" })
	set_hl("DiffChange", { bg = "#fb8500", fg = "#000000" })
	set_hl("DiffDelete", { bg = "#da3633", fg = "#ffffff" })
	set_hl("DiffText", { bg = "#ffa500", fg = "#000000", bold = true })

	-- Terminal colors
	vim.g.terminal_color_0 = "#1d2021" -- black
	vim.g.terminal_color_1 = "#fb4934" -- red
	vim.g.terminal_color_2 = "#b8bb26" -- green
	vim.g.terminal_color_3 = "#fabd2f" -- yellow
	vim.g.terminal_color_4 = "#83a598" -- blue
	vim.g.terminal_color_5 = "#d3869b" -- magenta
	vim.g.terminal_color_6 = "#8ec07c" -- cyan
	vim.g.terminal_color_7 = "#ebdbb2" -- white
	vim.g.terminal_color_8 = "#665c54" -- bright black
	vim.g.terminal_color_9 = "#fb4934" -- bright red
	vim.g.terminal_color_10 = "#b8bb26" -- bright green
	vim.g.terminal_color_11 = "#fabd2f" -- bright yellow
	vim.g.terminal_color_12 = "#83a598" -- bright blue
	vim.g.terminal_color_13 = "#d3869b" -- bright magenta
	vim.g.terminal_color_14 = "#8ec07c" -- bright cyan
	vim.g.terminal_color_15 = "#fbf1c7" -- bright white

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
	set_hl("TelescopeBorder", { fg = "#665c54" })
	set_hl("TelescopePromptBorder", { fg = "#fe8019" })
	set_hl("TelescopeResultsBorder", { fg = "#665c54" })
	set_hl("TelescopePreviewBorder", { fg = "#665c54" })

	-- LSP reference highlights
	set_hl("LspReferenceText", { bg = "#3c3836", underline = false })
	set_hl("LspReferenceRead", { bg = "#3c3836", underline = false })
	set_hl("LspReferenceWrite", { bg = "#3c3836", underline = false, bold = true })

	-- Better completion menu
	set_hl("Pmenu", { bg = "#1d2021", fg = "#ebdbb2" })
	set_hl("PmenuSel", { bg = "#fe8019", fg = "#1d2021", bold = true })
	set_hl("PmenuSbar", { bg = "#3c3836" })
	set_hl("PmenuThumb", { bg = "#fe8019" })
end

-- Create autocommand to apply highlights
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
	callback = apply_highlights,
})

-- Apply highlights immediately
apply_highlights()

return M

