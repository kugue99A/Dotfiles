-- Fast completion engine with native Neovim snippet support.
return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	lazy = false,
	opts = {
		keymap = {
			preset = "enter",
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
			},
			ghost_text = {
				enabled = true,
			},
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "source_name" },
					},
				},
			},
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
			completion = {
				menu = {
					auto_show = true,
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	},
	opts_extend = { "sources.default" },
}
