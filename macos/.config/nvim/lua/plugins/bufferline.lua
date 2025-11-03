-- Bufferline - A snazzy bufferline for Neovim
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned buffers" },
		{ "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other buffers" },
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<C-p>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<C-n>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
		{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
	},
	opts = {
		options = {
			close_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
			right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
			left_mouse_command = "buffer %d", -- can be a string | function, | false see "Mouse actions"
			middle_mouse_command = nil, -- can be a string | function, | false see "Mouse actions"

			indicator = {
				icon = "▎", -- this should be omitted if indicator style is not 'icon'
				style = "icon", -- can also be 'underline'|'none',
			},
			buffer_close_icon = "󱄊",
			modified_icon = "●",
			close_icon = "",
			left_trunc_marker = "",
			right_trunc_marker = "",

			max_name_length = 30,
			max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
			tab_size = 21,
			diagnostics = "nvim_lsp",
			diagnostics_update_in_insert = false,

			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				if context.buffer:current() then
					return ""
				end

				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,

			-- NOTE: this will be called a lot so don't do any heavy processing here
			custom_filter = function(buf_number, buf_numbers)
				-- filter out filetypes you don't want to see
				if vim.bo[buf_number].filetype ~= "oil" then
					return true
				end
				-- filter out by buffer name
				if vim.fn.bufname(buf_number) ~= "" then
					return true
				end
				-- filter out based on arbitrary rules
				-- e.g. filter out vim wiki buffer from tabline in your work repo
				if vim.fn.getcwd() == "/path/to/project" and vim.bo[buf_number].filetype ~= "wiki" then
					return true
				end
				-- filter out any buffer which path contains a certain string
				-- if string.find(vim.fn.bufname(buf_number), "string_to_match") then
				--   return false
				-- end
				return true
			end,

			offsets = {
				{
					filetype = "neo-tree",
					text = "Neo-tree",
					highlight = "Directory",
					text_align = "left",
				},
			},

			color_icons = true, -- whether or not to add the filetype icon highlights
			show_buffer_icons = true, -- disable filetype icons for buffers
			show_buffer_close_icons = true,
			show_close_icon = true,
			show_tab_indicators = true,
			show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
			persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
			move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
			-- can also be a table containing 2 custom separators
			-- [focused and unfocused]. eg: { '|', '|' }
			separator_style = "thin", -- | "slope" | "thick" | "slant" | { 'any', 'any' }
			enforce_regular_tabs = true,
			always_show_bufferline = true,
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			sort_by = "insert_after_current", -- |insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)

		-- Fix bufferline when restoring a session
		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
	end,
}
