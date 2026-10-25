local M = {}

local xdg_state_home = vim.env.XDG_STATE_HOME
local state_dir = xdg_state_home and xdg_state_home ~= ""
	and (xdg_state_home .. "/dotfiles")
	or vim.fn.expand("~/.local/state/dotfiles")
local state_file = state_dir .. "/theme"

local function read_background()
	local file = io.open(state_file, "r")
	if not file then
		return "dark"
	end

	local mode = file:read("*l")
	file:close()
	return mode == "light" and "light" or "dark"
end

function M.apply(background)
	background = background or read_background()
	background = background == "light" and "light" or "dark"
	vim.o.background = background
	local colorscheme = background == "light" and "ashes-light" or "tokyonight"
	return pcall(vim.cmd.colorscheme, colorscheme)
end

function M.setup()
	M.apply(read_background())

	local timer = vim.uv.new_timer()
	timer:start(1000, 1000, vim.schedule_wrap(function()
		local background = read_background()
		if vim.o.background == background then
			return
		end

		M.apply(background)
	end))

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			timer:stop()
			timer:close()
		end,
	})
end

return M
