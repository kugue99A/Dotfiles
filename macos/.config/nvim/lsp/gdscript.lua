-- GDScript LSP configuration
-- Requires Godot editor to be running (it starts LSP server on port 6005)
return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
  filetypes = { "gdscript", "gdshader" },
  root_markers = { "project.godot" },
  single_file_support = false,
}
