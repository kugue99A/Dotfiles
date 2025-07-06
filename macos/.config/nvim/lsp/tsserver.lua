return {
  single_file_support = false,
  root_dir = vim.lsp.util.root_pattern("package.json"),
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
  },
}