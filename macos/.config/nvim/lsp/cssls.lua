-- CSS Language Server configuration
return {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
  single_file_support = true,
  settings = {
    css = { validate = true },
    less = { validate = true },
    scss = { validate = true },
  },
}
