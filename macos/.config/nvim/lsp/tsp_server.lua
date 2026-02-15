-- TypeSpec Language Server configuration
return {
  cmd = { "tsp-server", "--stdio" },
  filetypes = { "typespec" },
  root_markers = { "tspconfig.yaml", ".git" },
  single_file_support = true,
}
