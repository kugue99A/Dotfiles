return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = function()
		if vim.fn.executable("tree-sitter") == 1 then
			vim.cmd("TSUpdate")
		end
	end,
	config = function()
		local treesitter = require("nvim-treesitter")
		local install_dir = vim.fn.stdpath("data") .. "/site"
		local languages = {
			"bash",
			"c",
			"css",
			"dockerfile",
			"gitignore",
			"go",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"rust",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		treesitter.setup({ install_dir = install_dir })
		vim.opt.runtimepath:prepend(install_dir)

		if vim.fn.executable("tree-sitter") == 1 then
			treesitter.install(languages)
		end

		local language_set = {}
		for _, language in ipairs(languages) do
			language_set[language] = true
		end

		local function is_large_file(bufnr)
			local name = vim.api.nvim_buf_get_name(bufnr)
			if name == "" then
				return false
			end
			local ok, stats = pcall(vim.uv.fs_stat, name)
			return ok and stats and stats.size > 100 * 1024
		end

		local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if not lang or not language_set[lang] or is_large_file(args.buf) then
					return
				end

				if pcall(vim.treesitter.start, args.buf, lang) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
