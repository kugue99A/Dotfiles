-- Deno Language Server configuration
return {
  cmd = { "deno", "lsp" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = { "deno.json", "deno.jsonc" },
  single_file_support = false,
  settings = {
    deno = {
      enable = true,
      lint = true,
      unstable = false,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
          },
        },
      },
    },
  },
}
