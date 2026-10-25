-- Ashes Light (terminal.sexy), adapted for Neovim.
local palette = {
	bg = "#F3F4F5",
	bg_alt = "#E5E6E7",
	fg = "#565E65",
	fg_dim = "#747C84",
	black = "#1C2023",
	red = "#C7AE95",
	green = "#95C7AE",
	yellow = "#AEC795",
	blue = "#AE95C7",
	magenta = "#C795AE",
	cyan = "#95AEC7",
	white = "#C7CCD1",
	black_bright = "#747C84",
	white_bright = "#F3F4F5",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.o.background = "light"
vim.g.colors_name = "ashes-light"
vim.g.terminal_color_0 = palette.black
vim.g.terminal_color_1 = palette.red
vim.g.terminal_color_2 = palette.green
vim.g.terminal_color_3 = palette.yellow
vim.g.terminal_color_4 = palette.blue
vim.g.terminal_color_5 = palette.magenta
vim.g.terminal_color_6 = palette.cyan
vim.g.terminal_color_7 = palette.white
vim.g.terminal_color_8 = palette.black_bright
vim.g.terminal_color_9 = palette.red
vim.g.terminal_color_10 = palette.green
vim.g.terminal_color_11 = palette.yellow
vim.g.terminal_color_12 = palette.blue
vim.g.terminal_color_13 = palette.magenta
vim.g.terminal_color_14 = palette.cyan
vim.g.terminal_color_15 = palette.white_bright

local groups = {
	Normal = { fg = palette.fg, bg = palette.bg },
	NormalNC = { fg = palette.fg, bg = palette.bg },
	NormalFloat = { fg = palette.fg, bg = palette.bg_alt },
	FloatBorder = { fg = palette.fg_dim, bg = palette.bg_alt },
	SignColumn = { bg = palette.bg },
	LineNr = { fg = palette.fg_dim, bg = palette.bg },
	CursorLine = { bg = palette.bg_alt },
	CursorLineNr = { fg = palette.black, bg = palette.bg_alt, bold = true },
	ColorColumn = { bg = palette.bg_alt },
	Folded = { fg = palette.fg_dim, bg = palette.bg_alt },
	FoldColumn = { fg = palette.fg_dim, bg = palette.bg },
	WinSeparator = { fg = palette.white, bg = palette.bg },
	VertSplit = { fg = palette.white, bg = palette.bg },
	EndOfBuffer = { fg = palette.bg_alt, bg = palette.bg },
	StatusLine = { fg = palette.fg, bg = palette.bg_alt },
	StatusLineNC = { fg = palette.fg_dim, bg = palette.bg_alt },
	TabLine = { fg = palette.fg_dim, bg = palette.bg_alt },
	TabLineFill = { bg = palette.bg_alt },
	TabLineSel = { fg = palette.black, bg = palette.bg, bold = true },
	Pmenu = { fg = palette.fg, bg = palette.bg_alt },
	PmenuSel = { fg = palette.black, bg = palette.white, bold = true },
	PmenuSbar = { bg = palette.white },
	PmenuThumb = { bg = palette.fg_dim },
	Visual = { fg = palette.black, bg = palette.white },
	Search = { fg = palette.black, bg = palette.yellow, bold = true },
	IncSearch = { fg = palette.bg, bg = palette.blue, bold = true },
	CurSearch = { fg = palette.bg, bg = palette.magenta, bold = true },
	MatchParen = { fg = palette.black, bg = palette.green, bold = true },
	Directory = { fg = palette.blue, bold = true },
	Title = { fg = palette.blue, bold = true },
	NonText = { fg = palette.fg_dim },
	Whitespace = { fg = palette.white },
	SpecialKey = { fg = palette.fg_dim },
	Comment = { fg = palette.fg_dim, italic = true },
	Constant = { fg = palette.cyan },
	String = { fg = palette.green },
	Character = { fg = palette.green },
	Number = { fg = palette.red },
	Boolean = { fg = palette.red },
	Float = { fg = palette.red },
	Identifier = { fg = palette.fg },
	Function = { fg = palette.blue },
	Statement = { fg = palette.magenta },
	Conditional = { fg = palette.magenta },
	Repeat = { fg = palette.magenta },
	Label = { fg = palette.yellow },
	Operator = { fg = palette.fg_dim },
	Keyword = { fg = palette.blue },
	Exception = { fg = palette.red },
	PreProc = { fg = palette.magenta },
	Include = { fg = palette.magenta },
	Define = { fg = palette.magenta },
	Macro = { fg = palette.magenta },
	Type = { fg = palette.yellow },
	StorageClass = { fg = palette.magenta },
	Structure = { fg = palette.yellow },
	Typedef = { fg = palette.yellow },
	Special = { fg = palette.cyan },
	SpecialChar = { fg = palette.red },
	Tag = { fg = palette.magenta },
	Delimiter = { fg = palette.fg_dim },
	SpecialComment = { fg = palette.fg_dim, italic = true },
	Underlined = { fg = palette.blue, underline = true },
	Error = { fg = palette.red, bold = true },
	Todo = { fg = palette.black, bg = palette.yellow, bold = true },
	DiagnosticError = { fg = palette.red },
	DiagnosticWarn = { fg = palette.red },
	DiagnosticInfo = { fg = palette.cyan },
	DiagnosticHint = { fg = palette.green },
	DiffAdd = { fg = palette.green, bg = "#E5EEE9" },
	DiffChange = { fg = palette.blue, bg = "#E7E8EE" },
	DiffDelete = { fg = palette.red, bg = "#F0E7E2" },
	DiffText = { fg = palette.black, bg = palette.white, bold = true },
	GitSignsAdd = { fg = palette.green },
	GitSignsChange = { fg = palette.blue },
	GitSignsDelete = { fg = palette.red },
	["@comment"] = { link = "Comment" },
	["@string"] = { link = "String" },
	["@character"] = { link = "Character" },
	["@number"] = { link = "Number" },
	["@boolean"] = { link = "Boolean" },
	["@constant"] = { link = "Constant" },
	["@constant.builtin"] = { fg = palette.red },
	["@variable"] = { fg = palette.fg },
	["@variable.builtin"] = { fg = palette.magenta },
	["@property"] = { fg = palette.fg },
	["@function"] = { link = "Function" },
	["@function.call"] = { fg = palette.blue },
	["@method"] = { fg = palette.blue },
	["@constructor"] = { fg = palette.yellow },
	["@parameter"] = { fg = palette.fg },
	["@keyword"] = { link = "Keyword" },
	["@conditional"] = { link = "Conditional" },
	["@operator"] = { link = "Operator" },
	["@type"] = { link = "Type" },
	["@type.builtin"] = { fg = palette.yellow },
	["@attribute"] = { fg = palette.red },
	["@markup.heading"] = { fg = palette.black, bold = true },
	["@markup.link"] = { fg = palette.blue, underline = true },
	["@markup.raw"] = { fg = palette.green },
	["@punctuation"] = { fg = palette.fg_dim },
}

for group, opts in pairs(groups) do
	vim.api.nvim_set_hl(0, group, opts)
end
