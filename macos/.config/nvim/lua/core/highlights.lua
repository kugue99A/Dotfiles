-- Modern highlight configuration
local M = {}

-- Helper function to set highlight groups
local function set_hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- Auto command to set highlights after colorscheme changes
local function apply_highlights()
	local is_ashes = vim.g.colors_name == "ashes-light"
	local colors
	if is_ashes then
		local terminal = {
			black = "#1C2023",
			red = "#C7AE95",
			green = "#95C7AE",
			yellow = "#AEC795",
			blue = "#AE95C7",
			magenta = "#C795AE",
			cyan = "#95AEC7",
			white = "#C7CCD1",
			black_bright = "#747C84",
			red_bright = "#C7AE95",
			green_bright = "#95C7AE",
			yellow_bright = "#AEC795",
			blue_bright = "#AE95C7",
			magenta_bright = "#C795AE",
			cyan_bright = "#95AEC7",
			white_bright = "#F3F4F5",
		}
		colors = {
			bg = "#F3F4F5",
			bg_dark = "#E5E6E7",
			bg_popup = "#E5E6E7",
			bg_highlight = "#DDE0E3",
			bg_visual = "#C7CCD1",
			bg_search = "#AEC795",
			border_highlight = "#747C84",
			fg = "#565E65",
			comment = "#747C84",
			red = "#C79595",
			orange = "#C7AE95",
			yellow = "#AEC795",
			green = "#95C7AE",
			blue = "#AE95C7",
			magenta = "#C795AE",
			cyan = "#95AEC7",
			error = "#C79595",
			warning = "#C7AE95",
			info = "#95AEC7",
			hint = "#95C7AE",
			diff = {
				add = "#DFEAE4",
				change = "#E2E6EE",
				delete = "#F0E4DF",
				text = "#C7CCD1",
			},
			terminal = terminal,
		}
	else
		local style = vim.o.background == "light" and "day" or "night"
		colors = require("tokyonight.colors").setup({ style = style })
	end
	local terminal = colors.terminal

	-- Keep the terminal transparent in Tokyo Night; Ashes uses its light canvas.
	local background = is_ashes and colors.bg or "NONE"
	set_hl("Normal", { bg = background, fg = colors.fg })
	set_hl("NormalNC", { bg = background, fg = colors.fg })
	set_hl("SignColumn", { bg = background })
	set_hl("LineNr", { bg = background })
	set_hl("Folded", { bg = is_ashes and colors.bg_dark or "NONE", fg = colors.comment })
	set_hl("EndOfBuffer", { bg = background, fg = colors.bg_highlight })

	-- Transparent tabline/bufferline
	set_hl("TabLine", { bg = is_ashes and colors.bg_dark or "NONE", fg = colors.comment })
	set_hl("TabLineFill", { bg = is_ashes and colors.bg_dark or "NONE" })
	set_hl("TabLineSel", { bg = colors.bg, fg = colors.fg, bold = true })

	-- Enhanced cursor line
	set_hl("CursorLineNr", { bold = true })

	-- Better visual selection
	set_hl("Visual", { bg = colors.bg_visual, fg = colors.fg })

	-- Improved search highlighting
	set_hl("Search", { bg = colors.bg_search, fg = colors.bg, bold = true })
	set_hl("IncSearch", { bg = colors.orange, fg = colors.bg, bold = true })

	-- Float window borders
	set_hl("FloatBorder", { fg = colors.border_highlight, bg = "NONE" })
	set_hl("NormalFloat", { bg = "NONE" })

	-- Diagnostic highlights
	set_hl("DiagnosticError", { fg = colors.error })
	set_hl("DiagnosticWarn", { fg = colors.warning })
	set_hl("DiagnosticInfo", { fg = colors.info })
	set_hl("DiagnosticHint", { fg = colors.hint })

	-- Better diff colors
	set_hl("DiffAdd", { bg = colors.diff.add, fg = colors.green })
	set_hl("DiffChange", { bg = colors.diff.change, fg = colors.blue })
	set_hl("DiffDelete", { bg = colors.diff.delete, fg = colors.red })
	set_hl("DiffText", { bg = colors.diff.text, fg = colors.fg, bold = true })

	-- Terminal colors
	vim.g.terminal_color_0 = terminal.black
	vim.g.terminal_color_1 = terminal.red
	vim.g.terminal_color_2 = terminal.green
	vim.g.terminal_color_3 = terminal.yellow
	vim.g.terminal_color_4 = terminal.blue
	vim.g.terminal_color_5 = terminal.magenta
	vim.g.terminal_color_6 = terminal.cyan
	vim.g.terminal_color_7 = terminal.white
	vim.g.terminal_color_8 = terminal.black_bright
	vim.g.terminal_color_9 = terminal.red_bright
	vim.g.terminal_color_10 = terminal.green_bright
	vim.g.terminal_color_11 = terminal.yellow_bright
	vim.g.terminal_color_12 = terminal.blue_bright
	vim.g.terminal_color_13 = terminal.magenta_bright
	vim.g.terminal_color_14 = terminal.cyan_bright
	vim.g.terminal_color_15 = terminal.white_bright

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

	-- LSP reference highlights
	set_hl("LspReferenceText", { bg = colors.bg_highlight, underline = false })
	set_hl("LspReferenceRead", { bg = colors.bg_highlight, underline = false })
	set_hl("LspReferenceWrite", { bg = colors.bg_highlight, underline = false, bold = true })

	-- Better completion menu
	set_hl("Pmenu", { bg = colors.bg_popup, fg = colors.fg })
	set_hl("PmenuSel", { bg = colors.blue, fg = colors.bg, bold = true })
	set_hl("PmenuSbar", { bg = colors.bg_dark })
	set_hl("PmenuThumb", { bg = colors.blue })
end

-- Create autocommand to apply highlights
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
	callback = apply_highlights,
})

-- Apply highlights immediately
apply_highlights()

return M
