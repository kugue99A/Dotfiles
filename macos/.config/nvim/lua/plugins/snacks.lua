-- snacks.nvim: image viewer, picker, and small UI utilities.
local function current_cwd()
	return vim.uv.cwd() or vim.fn.getcwd()
end

return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		input = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,
		},
		quickfile = { enabled = true },
		image = {
			enabled = true,
			doc = {
				enabled = true,
				inline = false, -- WezTerm doesn't support inline (Unicode placeholders)
				float = true, -- Use floating window instead
			},
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)

		local function picker_opts(args)
			if args and args:find("cwd=false", 1, true) then
				return { cwd = current_cwd() }
			end
			return {}
		end

		local telescope_pickers = {
			autocommands = function()
				Snacks.picker.autocmds()
			end,
			buffers = function()
				Snacks.picker.buffers()
			end,
			colorscheme = function()
				Snacks.picker.colorschemes()
			end,
			command_history = function()
				Snacks.picker.command_history()
			end,
			commands = function()
				Snacks.picker.commands()
			end,
			current_buffer_fuzzy_find = function()
				Snacks.picker.lines()
			end,
			diagnostics = function(args)
				if args and args:find("bufnr=0", 1, true) then
					Snacks.picker.diagnostics_buffer()
				else
					Snacks.picker.diagnostics()
				end
			end,
			find_files = function(args)
				Snacks.picker.files(picker_opts(args))
			end,
			git_commits = function()
				Snacks.picker.git_log()
			end,
			git_status = function()
				Snacks.picker.git_status()
			end,
			grep_string = function(args)
				Snacks.picker.grep_word(picker_opts(args))
			end,
			help_tags = function()
				Snacks.picker.help()
			end,
			highlights = function()
				Snacks.picker.highlights()
			end,
			keymaps = function()
				Snacks.picker.keymaps()
			end,
			live_grep = function(args)
				Snacks.picker.grep(picker_opts(args))
			end,
			loclist = function()
				Snacks.picker.loclist()
			end,
			lsp_document_symbols = function()
				Snacks.picker.lsp_symbols()
			end,
			lsp_dynamic_workspace_symbols = function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			man_pages = function()
				Snacks.picker.man()
			end,
			marks = function()
				Snacks.picker.marks()
			end,
			oldfiles = function()
				Snacks.picker.recent()
			end,
			pickers = function()
				Snacks.picker.pickers()
			end,
			quickfix = function()
				Snacks.picker.qflist()
			end,
			resume = function()
				Snacks.picker.resume()
			end,
		}

		vim.api.nvim_create_user_command("Telescope", function(cmd)
			local picker, args = cmd.args:match("^(%S+)%s*(.*)$")
			picker = picker or "pickers"
			args = args or ""

			local action = telescope_pickers[picker]
			if not action then
				vim.notify(
					("Telescope %s is replaced by Snacks picker, but no compatibility mapping exists yet."):format(
						picker
					),
					vim.log.levels.WARN
				)
				Snacks.picker.pickers()
				return
			end

			action(args)
		end, {
			nargs = "*",
			complete = function(arg_lead)
				local names = vim.tbl_keys(telescope_pickers)
				table.sort(names)
				return vim.tbl_filter(function(name)
					return vim.startswith(name, arg_lead)
				end, names)
			end,
		})
	end,
  -- stylua: ignore
  keys = {
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },

    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fF", function() Snacks.picker.files({ cwd = current_cwd() }) end, desc = "Find Files (cwd)" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },

    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Commits" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Status" },

    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fG", function() Snacks.picker.grep({ cwd = current_cwd() }) end, desc = "Grep (cwd)" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Word", mode = { "n", "x" } },
    { "<leader>sW", function() Snacks.picker.grep_word({ cwd = current_cwd() }) end, desc = "Word (cwd)", mode = { "n", "x" } },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sG", function() Snacks.picker.grep({ cwd = current_cwd() }) end, desc = "Grep (cwd)" },

    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Goto Symbol" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Goto Symbol (Workspace)" },

    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Auto Commands" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics_buffer() end, desc = "Document diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics() end, desc = "Workspace diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Search Highlight Groups" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Key Maps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Jump to Mark" },
    { "<leader>so", function() Snacks.picker.pickers() end, desc = "Pickers" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },

    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorscheme with preview" },
  },
}
